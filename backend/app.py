import os
import json
from flask import Flask, render_template, request, jsonify
from openai import OpenAI
import PyPDF2
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# -----------------------------
# NVIDIA API (OpenAI-compatible) — lazy init so /health works even if key is missing
# -----------------------------
_client = None


def _get_client():
    global _client
    if _client is None:
        base = os.environ.get("NVIDIA_BASE_URL", "https://integrate.api.nvidia.com/v1")
        key = os.environ.get("NVIDIA_API_KEY", "")
        _client = OpenAI(base_url=base, api_key=key)
    return _client


NVIDIA_MODEL = os.environ.get("NVIDIA_MODEL", "stepfun-ai/step-3.5-flash")
NVIDIA_TEMPERATURE = float(os.environ.get("NVIDIA_TEMPERATURE", "1"))
NVIDIA_TOP_P = float(os.environ.get("NVIDIA_TOP_P", "0.9"))
NVIDIA_MAX_TOKENS = int(os.environ.get("NVIDIA_MAX_TOKENS", "16384"))


@app.route("/")
def index():
    """Simple root response; web form uses /analyze_diagnosis."""
    try:
        return render_template("index.html")
    except Exception:
        return jsonify({"service": "masika-backend", "health": "/health", "predict": "POST /predict"})


@app.route("/health", methods=["GET"])
def health():
    """Used by Flutter app to check if analysis service is available."""
    return jsonify({"status": "ok"})


def _build_prompt(data, lab_report_text="No PDF report uploaded."):
    """Build the gynecologist analysis prompt from a data dict (keys can be form or input_data style)."""
    # Normalize keys: support both form names and Flutter input_data names
    def get(key, *alt_keys, default=""):
        for k in (key,) + alt_keys:
            v = data.get(k)
            if v is not None and str(v).strip() != "":
                return str(v).strip()
        return default or ""

    name = get("name", default="User")
    return f"""
    Act as a highly experienced senior gynecologist. Analyze the following patient data.

    PATIENT DETAILS:
    - Name: {name}
    - Age: {get('current_age', 'currentAge')}
    - Age of First Period: {get('first_period_age', 'ageAtFirstPeriod')}

    MENSTRUAL CYCLE HISTORY:
    - Cycle Length: {get('cycle_length', 'cycleLength')} days
    - Period Duration: {get('period_length', 'periodDuration')} days
    - Regularity: {get('period_regularity', 'regularity')}
    - Missed Periods recently: {get('missed_period', 'missedPeriod')}

    CURRENT SYMPTOMS:
    - Flow Rate: {get('flow_rate', 'flowRate')}
    - Pads used per day: {get('pads_used', 'padsPerDay')}
    - Blood Clots: {get('clots', 'bloodClots')}
    - Pain/Cramps: {get('pain', 'painLevel')}
    - Weakness: {get('weakness', 'weaknessDizziness')}

    LIFESTYLE:
    - Diet: {get('diet')}

    LAB REPORTS (OCR EXTRACTED):
    - Hemoglobin/CBC Input: {get('hemoglobin_manual', 'hemoglobin')}
    - PDF Text Content: {lab_report_text}

    USER COMPLAINT:
    - {get('description', 'otherSymptoms')}

    OUTPUT FORMAT:
    You must strictly respond with a valid JSON object ONLY. No markdown, no introductory text.
    JSON structure:
    {{
        "diagnosis_result": "NORMAL" or "ABNORMAL",
        "reason_summary": "A brief empathetic summary (1-2 sentences) for the Wellness Report Summary.",
        "key_observation": "Main clinical findings and what stands out from the data (2-4 clear points).",
        "suggested_next_steps": "Concrete steps the user should take (lifestyle, follow-up, tests). Number or bullet in plain text.",
        "important_note": "One clear disclaimer: this is not a substitute for a doctor; when to seek care; key caution."
    }}

    Rules: "ABNORMAL" if Hemoglobin < 11, pads > 8, severe pain, or missed periods.
    """


def _build_structured_report(ai_result):
    """Build a structured report string: Wellness Report Summary, Key observation, Suggested next steps, Important note."""
    def get(*keys, default=""):
        for k in keys:
            v = ai_result.get(k)
            if v is not None and str(v).strip():
                return str(v).strip()
        return default

    summary = get("reason_summary", default="")
    key_obs = get("key_observation", "detailed_abnormal_note")
    next_steps = get("suggested_next_steps", "plan_actions")
    important = get("important_note", "doctor_visit_trigger", "consult_recommendation")

    parts = []
    if summary:
        parts.append("Wellness Report Summary\n" + summary)
    if key_obs:
        parts.append("Key observation:\n" + key_obs)
    if next_steps:
        parts.append("Suggested next steps:\n" + next_steps)
    if important:
        parts.append("Important note about this analysis:\n" + important)
    return "\n\n".join(parts) if parts else summary or "No report content available."


def _call_nvidia_and_parse(prompt):
    """Call NVIDIA API and return parsed JSON result. Raises on error."""
    completion = _get_client().chat.completions.create(
        model=NVIDIA_MODEL,
        messages=[{"role": "user", "content": prompt}],
        temperature=NVIDIA_TEMPERATURE,
        top_p=NVIDIA_TOP_P,
        max_tokens=NVIDIA_MAX_TOKENS,
        stream=False,
    )
    result_text = completion.choices[0].message.content or ""
    result_text = result_text.replace("```json", "").replace("```", "").strip()
    return json.loads(result_text)


@app.route("/predict", methods=["POST"])
def predict():
    """
    Flutter app endpoint: JSON body { "features": [12], "input_data": {...} }.
    Returns { "prediction": "NORMAL"|"ABNORMAL", "report": "..." }.
    """
    try:
        body = request.get_json(force=True, silent=True) or {}
        features = body.get("features") or []
        input_data = body.get("input_data") or {}
        if len(features) != 12:
            return jsonify({"error": "Exactly 12 features required"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 400

    prompt = _build_prompt(input_data)
    try:
        ai_result = _call_nvidia_and_parse(prompt)
    except json.JSONDecodeError as e:
        print("JSON parse error:", e)
        return jsonify({"error": f"Model did not return valid JSON: {str(e)}"}), 500
    except Exception as e:
        print("NVIDIA API Error:", e)
        return jsonify({"error": str(e)}), 500

    diagnosis = (ai_result.get("diagnosis_result") or "NORMAL").strip().upper()
    if diagnosis not in ("NORMAL", "ABNORMAL"):
        diagnosis = "NORMAL"

    report = _build_structured_report(ai_result)
    return jsonify({
        "prediction": diagnosis,
        "probabilities": {},
        "report": report or None,
    })


@app.route("/analyze_diagnosis", methods=["POST"])
def analyze_diagnosis():
    # 1. Gather Form Data
    data = {
        "name": request.form.get("name"),
        "current_age": request.form.get("current_age"),
        "first_period_age": request.form.get("first_period_age"),
        "cycle_length": request.form.get("cycle_length"),
        "period_length": request.form.get("period_length"),
        "period_regularity": request.form.get("period_regularity"),
        "missed_period": request.form.get("missed_period"),
        "flow_rate": request.form.get("flow_rate"),
        "pads_used": request.form.get("pads_used"),
        "clots": request.form.get("clots"),
        "pain": request.form.get("pain"),
        "weakness": request.form.get("weakness"),
        "diet": request.form.get("diet"),
        "hemoglobin_manual": request.form.get("hemoglobin_manual"),
        "description": request.form.get("description"),
    }

    # 2. Handle File Upload (CBC/Report PDF)
    lab_report_text = "No PDF report uploaded."
    if "hemoglobin_file" in request.files:
        file = request.files["hemoglobin_file"]
        if file.filename != "":
            try:
                pdf_reader = PyPDF2.PdfReader(file)
                extracted_text = ""
                for page in pdf_reader.pages:
                    extracted_text += page.extract_text()
                lab_report_text = extracted_text if extracted_text else "Could not read text from PDF."
            except Exception as e:
                lab_report_text = f"Error reading PDF: {str(e)}"

    prompt = _build_prompt(data, lab_report_text)
    try:
        ai_result = _call_nvidia_and_parse(prompt)
        return jsonify({"status": "success", "data": ai_result})
    except json.JSONDecodeError as e:
        print("JSON parse error:", e)
        return jsonify({"status": "error", "message": f"Model did not return valid JSON: {str(e)}"})
    except Exception as e:
        print("NVIDIA API Error:", e)
        return jsonify({"status": "error", "message": str(e)})


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=os.environ.get("FLASK_ENV") == "development")
