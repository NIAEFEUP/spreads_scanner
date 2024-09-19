import 'package:flutter/widgets.dart';
import 'package:jantar_de_curso_scanner/http/client/authenticated.dart';
import 'package:jantar_de_curso_scanner/session/authentication_controller.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AuthenticatedClientProvider extends StatelessWidget {
  const AuthenticatedClientProvider(
      {super.key, required this.client, required this.child});

  final Widget child;

  final http.Client client;

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<AuthenticationController?, http.Client>(
      update: (_, controller, __) => controller != null
          ? AuthenticatedClient(
              client,
              controller: controller,
            )
          : client,
      child: child,
    );
  }
}
