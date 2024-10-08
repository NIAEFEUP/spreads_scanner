import 'package:flutter/material.dart';
import 'package:jantar_de_curso_scanner/pages/qrcode_scanner.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:intl/intl.dart';

final _googleSignIn = GoogleSignIn(
  scopes: <String>[
    drive.DriveApi.driveReadonlyScope,
    sheets.SheetsApi.spreadsheetsScope,
  ],
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  drive.DriveApi? driveApi;
  sheets.SheetsApi? sheetsApi;

  sheets.Spreadsheet? selectedSpreadSheet;
  sheets.Sheet? selectedSheet;

  sheets.CellData? upCell;
  sheets.CellData? checkCell;

  var loadingSpreadSheet = false;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
      assert(client != null, 'Authenticated client missing!');

      setState(() {
        driveApi = drive.DriveApi(client!);
        sheetsApi = sheets.SheetsApi(client);
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> openDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        TextEditingController searchController = TextEditingController();
        List<drive.File> searchResults = [];
        bool isLoading = false;

        Future<void> searchFiles(String query, StateSetter setState) async {
          setState(() {
            isLoading = true;
          });

          // Perform file search using the Drive API
          final result = await driveApi!.files.list(
            q: "name contains '$query' and mimeType = 'application/vnd.google-apps.spreadsheet'",
            spaces: 'drive',
            $fields: 'files(id, name, createdTime)',
          );

          setState(() {
            searchResults = result.files ?? [];
            isLoading = false;
          });
        }

        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setInsideState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Procurar Spreadsheet',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        searchFiles(value, setInsideState);
                      } else {
                        setInsideState(() {
                          searchResults.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const CircularProgressIndicator()
                      : searchResults.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: searchResults.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final file = searchResults[index];
                                  final creationDate =
                                      file.createdTime?.toLocal();
                                  final creationDateText = creationDate != null
                                      ? DateFormat('dd/MM/yyyy')
                                          .format(creationDate)
                                      : 'Desconhecido';

                                  return ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    title: Text(file.name ?? 'Sem Nome'),
                                    subtitle:
                                        Text('Criado em: $creationDateText'),
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      setState(() => loadingSpreadSheet = true);
                                      final spread =
                                          await sheetsApi!.spreadsheets.get(
                                        file.id!,
                                        includeGridData: true,
                                      );
                                      setState(() {
                                        selectedSheet = null;
                                        selectedSpreadSheet = spread;
                                        loadingSpreadSheet = false;
                                      });
                                    },
                                  );
                                },
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.all(15),
                              child: Text('Sem resultados'),
                            ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 32, 39),
      appBar: AppBar(
        title: const Text('Spreads Scanner'),
        actions: <Widget>[
          Visibility(
            visible: _googleSignIn.currentUser != null &&
                driveApi != null &&
                sheetsApi != null,
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => setState(() {
                _googleSignIn.disconnect();
                driveApi = null;
                sheetsApi = null;
                selectedSpreadSheet = null;
                selectedSheet = null;
                upCell = null;
                checkCell = null;
              }),
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_googleSignIn.currentUser == null ||
                driveApi == null ||
                sheetsApi == null)
              ElevatedButton(
                onPressed: () => _googleSignIn.signIn(),
                child: const Text('Login com Google'),
              ),
            const SizedBox(height: 16),

            if (loadingSpreadSheet) const CircularProgressIndicator(),

            if (_googleSignIn.currentUser != null &&
                driveApi != null &&
                sheetsApi != null &&
                !loadingSpreadSheet &&
                selectedSpreadSheet == null)
              ElevatedButton(
                onPressed: openDialog,
                child: const Text('Selecionar Spread'),
              ),

            // Displat the name of the spread with a button to delete it
            if (selectedSpreadSheet != null)
              Container(
                  padding: const EdgeInsets.fromLTRB(10, 3, 3, 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.file_present),
                      const SizedBox(width: 5),
                      Text(
                          selectedSpreadSheet!.properties!.title ??
                              'Sem Título',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 1),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            selectedSpreadSheet = null;
                            selectedSheet = null;
                            upCell = null;
                            checkCell = null;
                          });
                        },
                      ),
                    ],
                  )),
            if (selectedSpreadSheet != null)
              Column(children: <Widget>[
                const SizedBox(height: 10),
                Text("Folha da Spread",
                    style: Theme.of(context).primaryTextTheme.bodyMedium),
                Container(
                    constraints: const BoxConstraints(maxWidth: 250),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButton<sheets.Sheet>(
                      underline: Container(),
                      focusColor: Theme.of(context).colorScheme.secondary,
                      value: selectedSheet,
                      items: selectedSpreadSheet!.sheets!
                          .map((sheet) => DropdownMenuItem(
                                value: sheet,
                                child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 200),
                                    child: Text(
                                      sheet.properties!.title ?? 'Sem Título',
                                      overflow: TextOverflow.ellipsis,
                                    )),
                              ))
                          .toList(),
                      onChanged: (sheet) {
                        setState(() {
                          selectedSheet = sheet;
                        });
                      },
                    ))
              ]),
            if (selectedSheet != null)
              Column(children: <Widget>[
                const SizedBox(height: 10),
                Text("Coluna Identificação",
                    style: Theme.of(context).primaryTextTheme.bodyMedium),
                Container(
                  constraints: const BoxConstraints(maxWidth: 250),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton<sheets.CellData>(
                    underline: Container(),
                    value: upCell,
                    items: selectedSheet!.data!.first.rowData!.first.values!
                        .map(
                          (data) => DropdownMenuItem(
                              value: data,
                              child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 200),
                                  child: Text(
                                    data.formattedValue ?? 'Sem Título',
                                    overflow: TextOverflow.ellipsis,
                                  ))),
                        )
                        .toList(),
                    onChanged: (data) {
                      setState(() {
                        if (data != null) {
                          upCell = data;
                        }
                      });
                    },
                  ),
                )
              ]),
            // the same as above but for checkCell
            if (selectedSheet != null)
              Column(children: <Widget>[
                const SizedBox(height: 10),
                Text("Coluna Check-in",
                    style: Theme.of(context).primaryTextTheme.bodyMedium),
                Container(
                    constraints: const BoxConstraints(maxWidth: 250),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButton<sheets.CellData>(
                      underline: Container(),
                      value: checkCell,
                      items: selectedSheet!.data!.first.rowData!.first.values!
                          .map((data) => DropdownMenuItem(
                                value: data,
                                child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 200),
                                    child: Text(
                                      data.formattedValue ?? 'Sem Título',
                                      overflow: TextOverflow.ellipsis,
                                    )),
                              ))
                          .toList(),
                      onChanged: (data) {
                        setState(() {
                          if (data != null) {
                            checkCell = data;
                          }
                        });
                      },
                    )),
              ]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (sheetsApi == null ||
              selectedSheet == null ||
              upCell == null ||
              checkCell == null) {
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRCodeScannerPage(
                  sheetsApi: sheetsApi!,
                  spreadsheetId: selectedSpreadSheet!.spreadsheetId!,
                  sheetName: selectedSheet!.properties!.title!,
                  upCell: upCell!,
                  checkCell: checkCell!),
            ),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
