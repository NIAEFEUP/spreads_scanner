import 'package:flutter/material.dart';
import 'package:jantar_de_curso_scanner/http/client/timeout.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:jantar_de_curso_scanner/pages/login.dart';
import 'package:jantar_de_curso_scanner/providers/authentication/authentication.dart';
import 'package:jantar_de_curso_scanner/providers/http.dart';
import 'package:jantar_de_curso_scanner/theme.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

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
      home: AuthenticationProvider(
        child: AuthenticatedClientProvider(
          client: TimeoutClient(
            http.Client(),
            timeout: const Duration(seconds: 15),
          ),
          child: const LoginPage(),
        ),
      ),
    );
  }
}
