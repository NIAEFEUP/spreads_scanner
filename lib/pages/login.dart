import 'package:flutter/material.dart';
import 'package:jantar_de_curso_scanner/app_links/app_links.dart';
import 'package:jantar_de_curso_scanner/pages/homepage.dart';
import 'package:jantar_de_curso_scanner/providers/authentication/notifier.dart';
import 'package:jantar_de_curso_scanner/session/flows/federated/initiator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _onLoginPressed(BuildContext context) async {
    final appLinks = ScannerAppLinks();

    final initiator = FederatedSessionInitiator(
      clientId: 'mobile-app-niaefeup-jantar-de-curso',
      realm: Uri(
        scheme: "https",
        host: "open-id.up.pt",
        path: "/realms/sigarra",
      ),
      performAuthentication: (flow) async {
        final data = await appLinks.login.intercept((redirectUri) async {
          flow.redirectUri = redirectUri;
          await launchUrl(flow.authenticationUri);
        });

        await closeInAppWebView();

        return data;
      },
    );

    final authenticationNotifier =
        Provider.of<AuthenticationNotifier>(context, listen: false);

    await authenticationNotifier.login(initiator);

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _onLoginPressed(context),
          child: const Text('Efetuar login federado'),
        ),
      ),
    );
  }
}
