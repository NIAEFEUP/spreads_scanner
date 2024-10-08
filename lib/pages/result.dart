import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final bool found;
  final String scanned;
  final List<Object?>? header;
  final List<Object?>? data;
  final bool? alreadyChecked;

  const ResultPage(
      {Key? key,
      required this.found,
      required this.scanned,
      this.header,
      this.data,
      this.alreadyChecked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    if (found) {
      if (alreadyChecked == true) {
        iconData = Icons.warning;
        iconColor = Colors.yellow;
      } else {
        iconData = Icons.check_circle;
        iconColor = Colors.green;
      }
    } else {
      iconData = Icons.error;
      iconColor = Colors.red;
    }

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 27, 32, 39),
        appBar: AppBar(
          title: const Text('Resultado'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    color: iconColor,
                    size: 50,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    found
                        ? (alreadyChecked == true ? 'Já verificado' : 'Sucesso')
                        : 'Não Encontrado',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Valor do QRCode',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  scanned,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),
              if (header != null && data != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(header!.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Text(
                              '${header![index]}: ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              index < data!.length
                                  ? data![index].toString()
                                  : 'N/A',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ));
  }
}
