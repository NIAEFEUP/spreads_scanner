import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:jantar_de_curso_scanner/pages/result.dart';

class QRCodeScannerPage extends StatefulWidget {
  sheets.SheetsApi sheetsApi;
  String spreadsheetId;
  String sheetName;
  sheets.CellData upCell;
  sheets.CellData checkCell;

  QRCodeScannerPage(
      {required this.sheetsApi,
      required this.spreadsheetId,
      required this.sheetName,
      required this.upCell,
      required this.checkCell,
      Key? key})
      : super(key: key);

  @override
  QRCodeScannerPageState createState() => QRCodeScannerPageState();
}

class QRCodeScannerPageState extends State<QRCodeScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  //TODO: Remove this code here
  @override
  void initState() {
    super.initState();
    _searchInSpreadsheet('202305089');
  }

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

  Future<void> _searchInSpreadsheet(String value) async {
    try {
      final sheetsApi = widget.sheetsApi;
      final spreadsheetId = widget.spreadsheetId;
      final sheetName = widget.sheetName;

      final response =
          await sheetsApi.spreadsheets.values.get(spreadsheetId, sheetName);

      if (response.values == null || response.values!.isEmpty) {
        return;
      }

      final header = response.values?.first;
      if (header == null) return;

      final upColumnIndex = header.indexOf(widget.upCell.formattedValue);
      final entryIndex = header.indexOf(widget.checkCell.formattedValue);

      List<Object?>? foundRow;
      for (var row in response.values!) {
        final upCellValue = row[upColumnIndex];

        if (upCellValue == value) {
          foundRow = row;
        }
      }

      var alreadyChecked = false;
      if (foundRow != null && entryIndex < foundRow.length) {
        alreadyChecked =
            foundRow[entryIndex] != null && foundRow[entryIndex] != '';
      }
      if (!alreadyChecked && foundRow != null) {
        final now = DateTime.now();
        final formattedDateTime = now.toString();

        final value = sheets.ValueRange(values: [
          [formattedDateTime]
        ]);

        final rowIndex = response.values!.indexOf(foundRow) + 1;
        final column = String.fromCharCode(65 + entryIndex);
        final range = '$sheetName!$column$rowIndex:$column$rowIndex';

        await sheetsApi.spreadsheets.values.update(value, spreadsheetId, range,
            valueInputOption: 'USER_ENTERED');
      }

      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResultPage(
                  found: foundRow != null,
                  scanned: value,
                  header: header,
                  data: foundRow,
                  alreadyChecked: alreadyChecked)));
    } catch (e) {
      print('Error searching in spreadsheet: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 32, 39),
      appBar: AppBar(
        title: const Text('Ler QRCode'),
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
