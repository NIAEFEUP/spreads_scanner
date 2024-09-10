import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:jantar_de_curso_scanner/pages/result.dart';

import 'package:intl/intl.dart';

class QRCodeScannerPage extends StatefulWidget {
  const QRCodeScannerPage({Key? key}) : super(key: key);

  @override
  QRCodeScannerPageState createState() => QRCodeScannerPageState();
}

class QRCodeScannerPageState extends State<QRCodeScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code == null) return;
      try {
        controller.dispose();
        await _searchInSpreadsheet(scanData.code!);
      } catch (error) {
        print('Error scanning QR code: $error');
      }
    });
  }

  String convertToDateTime(double numericalValue) {
    // Extract integer and fractional parts
    int daysSinceEpoch = numericalValue.floor();
    double fractionalPart = numericalValue - daysSinceEpoch;

    // Calculate the time
    int totalSeconds = (fractionalPart * 24 * 3600).round();
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    String formattedTime = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    // Return the combined date and time
    return formattedTime;
  }

  Future<void> _searchInSpreadsheet(String up_number) async {
    try {
      final creds = auth.ServiceAccountCredentials.fromJson({});

      // Create an authenticated client
      final client = await auth.clientViaServiceAccount(creds,
          [drive.DriveApi.driveFileScope, sheets.SheetsApi.spreadsheetsScope]);

      // Initialize Sheets API
      final sheetsApi = sheets.SheetsApi(client);

      // Spreadsheet ID of the specific spreadsheet you want to interact with
      const String spreadsheetId = "";

      final response = await sheetsApi.spreadsheets.values.get(
          spreadsheetId, "Confirmados",
          valueRenderOption: 'UNFORMATTED_VALUE');

      // Process the response
      if (response.values != null) {
        // Extract the values from the response
        final values = response.values;

        // Find the index of the column named "UP"
        final headerRow = values?.first;
        if (headerRow == null) return;
        final upColumnIndex = headerRow.indexOf('Número UP');
        final entryIndex = headerRow.indexOf('Entrada');

        // Search for the row where the value of the "UP" column matches the specified value
        List<dynamic>? targetRow;
        for (final row in values!.skip(1)) {
          if (row.length > upColumnIndex &&
              row[upColumnIndex].toString() == up_number) {
            targetRow = row;
            if (row.length >= entryIndex + 1 &&
                targetRow[entryIndex] is double) {
              targetRow[entryIndex] = convertToDateTime(targetRow[entryIndex]);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResultPage(
                        found: true,
                        scanned: up_number,
                        header: headerRow,
                        data: targetRow,
                        alreadyEnter: true)),
              );
              return;
            }
            break;
          }
        }

        if (targetRow != null) {
          final now = DateTime.now();
          final formattedDateTime = now.toString();

          targetRow.add(formattedDateTime);

          final value = sheets.ValueRange(values: [
            [formattedDateTime]
          ]);

          final rowIndex = values.indexOf(targetRow) + 1;
          final lastColumn = headerRow.length;
          final column = String.fromCharCode(65 + lastColumn - 1);
          final range = 'Confirmados!$column$rowIndex:$column$rowIndex';

          await sheetsApi.spreadsheets.values.update(
              value, spreadsheetId, range,
              valueInputOption: 'USER_ENTERED');

          targetRow.last = DateFormat('HH:mm:ss').format(now);

          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResultPage(
                    found: true,
                    scanned: up_number,
                    header: headerRow,
                    data: targetRow)),
          );
        } else {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ResultPage(found: false, scanned: up_number)),
          );
        }
      }
    } catch (error) {
      print('Error requesting spreadsheet file: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      ),
    );
  }
}
