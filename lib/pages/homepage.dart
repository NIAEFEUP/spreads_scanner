import 'package:flutter/material.dart';
import 'package:jantar_de_curso_scanner/pages/qrcode_scanner.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

final _googleSignIn = GoogleSignIn(
  scopes: <String>[
    DriveApi.driveReadonlyScope,
    SheetsApi.spreadsheetsScope,
  ],
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  DriveApi? driveApi;
  SheetsApi? sheetsApi;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
      assert(client != null, 'Authenticated client missing!');

      driveApi = DriveApi(client!);
      sheetsApi = SheetsApi(client);
    });
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Jantar de Curso Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _googleSignIn.signIn(),
              child: const Text('Login com Google'),
            ),
            ElevatedButton(
              onPressed: () => _googleSignIn.disconnect(),
              child: const Text('Loggout'),
            ),
            //button to open a dialog to search for the sheet
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QRCodeScannerPage(),
            ),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
