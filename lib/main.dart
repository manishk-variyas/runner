import 'package:flutter/material.dart';
import 'package:runner/screens/connection_list_screen.dart';
import 'package:runner/services/session_manager.dart';
import 'package:runner/theme/theme_controller.dart';

final sessionManager = SessionManager();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
