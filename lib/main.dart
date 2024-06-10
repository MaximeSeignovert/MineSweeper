import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minesweeper/auth_gate.dart';
import 'package:minesweeper/firebase_options.dart';
import 'package:minesweeper/riverpod/providers.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkModeEnabled = ref.watch(darkModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkModeEnabled ? darkTheme : lightTheme,
      home: const AuthGate(),
    );
  }
}

// Thème sombre
var darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.red,
);

// Thème clair
var lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
);
