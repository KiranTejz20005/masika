import 'package:flutter/material.dart';

import '../services/ml_backend_service.dart';

/// Wraps the first screen after splash. Runs GET /health once; if it fails,
/// shows a dialog "Analysis service unavailable." without crashing the app.
class AnalysisServiceCheckWrapper extends StatefulWidget {
  const AnalysisServiceCheckWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AnalysisServiceCheckWrapper> createState() =>
      _AnalysisServiceCheckWrapperState();
}

class _AnalysisServiceCheckWrapperState extends State<AnalysisServiceCheckWrapper> {
  static bool _dialogShownThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkHealth());
  }

  Future<void> _checkHealth() async {
    if (_dialogShownThisSession || !mounted) return;
    bool ok = false;
    try {
      ok = await MlBackendService().checkHealth();
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    if (!ok) {
      _dialogShownThisSession = true;
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: const Text('Analysis service unavailable'),
          content: const Text(
            'The analysis service could not be reached. '
            'You can still use the app; analysis features may not work until the service is available.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
