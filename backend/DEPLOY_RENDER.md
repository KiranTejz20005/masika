# Deploy Masika Backend on Render

Step-by-step guide to deploy the Flask backend (NVIDIA API, `/health`, `/predict`) as a **Web Service** on [Render](https://render.com).

---

## Prerequisites

- Code pushed to **GitHub** (e.g. `KiranTejz20005/masika`)
- A **Render** account (sign up at [render.com](https://render.com))
- Your **NVIDIA API key** (from [build.nvidia.com](https://build.nvidia.com))

---

## Step 1: Sign in to Render

1. Go to [https://render.com](https://render.com).
2. Click **Get Started** or **Sign In**.
3. Sign in with **GitHub** (recommended so Render can access your repo).

---

## Step 2: Create a new Web Service

1. From the **Dashboard**, click **New +** → **Web Service**.
2. If asked to connect a repository:
   - Click **Connect account** (GitHub) if not already connected.
   - Find and select your repo: **KiranTejz20005/masika** (or your fork).
   - Click **Connect**.

---

## Step 3: Configure the service

Use these settings. Render may auto-detect Python; if not, set them manually.

| Field | Value |
|--------|--------|
| **Name** | `masika-backend` (or any name you like) |
| **Region** | Choose closest to your users (e.g. Oregon, Frankfurt) |
| **Branch** | `main` |
| **Root Directory** | `backend` |
| **Runtime** | **Python 3** |
| **Build Command** | `pip install -r requirements.txt` |
| **Start Command** | `gunicorn --bind 0.0.0.0:$PORT app:app` |

Important: **Root Directory** must be `backend` so Render runs commands and finds `app.py` and `requirements.txt` inside `backend/`.

---

## Step 4: Add environment variables

In the same screen, open the **Environment** (or **Environment Variables**) section and add:

| Key | Value | Notes |
|-----|--------|--------|
| `NVIDIA_API_KEY` | Your NVIDIA API key | Required (e.g. `nvapi-...`) |
| `NVIDIA_BASE_URL` | `https://integrate.api.nvidia.com/v1` | Optional; this is the default |
| `NVIDIA_MODEL` | `stepfun-ai/step-3.5-flash` | Optional |
| `NVIDIA_TEMPERATURE` | `1` | Optional |
| `NVIDIA_TOP_P` | `0.9` | Optional |
| `NVIDIA_MAX_TOKENS` | `16384` | Optional |

Do **not** put secrets in the repo; only in Render’s Environment tab.

---

## Step 5: Choose a plan and create

1. Select **Free** (or a paid plan if you prefer).
2. Click **Create Web Service**.
3. Render will clone the repo, run the build command, then the start command. First deploy may take a few minutes.

---

## Step 6: Get your backend URL

1. When the deploy finishes, the **Logs** should show something like: `Listening at: http://0.0.0.0:XXXX`.
2. At the top of the service page you’ll see the public URL, e.g.  
   `https://masika-backend-xxxx.onrender.com`
3. Test:
   - **Health:** open `https://<your-service>.onrender.com/health` in a browser. You should see `{"status":"ok"}`.
   - **Predict:** your Flutter app will call `https://<your-service>.onrender.com/predict` (POST with JSON).

---

## Step 7: Point the Flutter app at the deployed backend

1. In your **frontend** `.env` (locally), set:
   ```env
   ML_BACKEND_URL=https://masika-backend-xxxx.onrender.com
   ```
   (Use the **exact** URL from Step 6; no trailing slash.)
2. If your backend ever requires an API key in the request, set:
   ```env
   ML_API_KEY=your-api-key
   ```
   (The current backend does not require this for `/health` or `/predict`.)

Rebuild/run the Flutter app; it will use the Render backend.

---

## Troubleshooting

| Issue | What to do |
|--------|------------|
| **502 Bad Gateway** | Service not starting. In Dashboard: set **Root Directory** to `backend`; check **Logs** (Build + Deploy) for errors; set **Start Command** to `gunicorn --bind 0.0.0.0:$PORT app:app`; add env var `NVIDIA_API_KEY`. |
| Build fails | Check **Logs** for errors. Ensure **Root Directory** is `backend` and `requirements.txt` is there. |
| “Application failed to respond” | Confirm **Start Command** is `gunicorn --bind 0.0.0.0:$PORT app:app` and that `gunicorn` is in `requirements.txt`. |
| 503 or timeouts on Free tier | Free services spin down after inactivity. First request after idle can take 30–60 seconds; retry once. |
| `/predict` returns 500 | In Render **Logs**, check for NVIDIA API errors. Verify `NVIDIA_API_KEY` is set correctly in **Environment**. |
| CORS errors from Flutter | If you need CORS, add `flask-cors` to `requirements.txt` and enable CORS in `app.py` for your frontend origin. |

---

## Summary checklist

- [ ] Render account created and GitHub repo connected.
- [ ] New **Web Service** with **Root Directory** = `backend`.
- [ ] **Build Command:** `pip install -r requirements.txt`
- [ ] **Start Command:** `gunicorn --bind 0.0.0.0:$PORT app:app`
- [ ] Environment variables set (at least `NVIDIA_API_KEY`).
- [ ] Deploy succeeded and `/health` returns `{"status":"ok"}`.
- [ ] Flutter `.env` updated with `ML_BACKEND_URL=https://<your-app>.onrender.com`.

After that, your backend is deployed on Render and the app can use it from anywhere.
