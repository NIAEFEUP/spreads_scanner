import 'package:flutter/material.dart';

import 'package:jantar_de_curso_scanner/pages/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jantar_de_curso_scanner/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spreads Scanner',
      theme: AppTheme.theme,
      home: const HomePage(),
    );
  }
}
