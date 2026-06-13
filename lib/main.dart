import 'package:flutter/material.dart';
import 'package:runner/screens/connection_list_screen.dart';
import 'package:runner/services/session_manager.dart';
import 'package:runner/theme/theme_controller.dart';

final sessionManager = SessionManager();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RunnerApp());
}

class RunnerApp extends StatefulWidget {
  const RunnerApp({super.key});

  @override
  State<RunnerApp> createState() => _RunnerAppState();
}

class _RunnerAppState extends State<RunnerApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      sessionManager.closeAllSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp(
        title: 'Runner',
        debugShowCheckedModeBanner: false,
        theme: themeController.themeData,
        home: ConnectionListScreen(manager: sessionManager),
      ),
    );
  }
}
