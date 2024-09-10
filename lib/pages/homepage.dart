import 'package:flutter/material.dart';

import 'package:jantar_de_curso_scanner/pages/qrcode_scanner.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF374151),
      appBar: AppBar(
        title: const Text('Jantar de Curso Scanner'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const QRCodeScannerPage(),
              ),
            );
          },
          child: const Text('Validar Entrada'),
        ),
      ),
    );
  }
}
