import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jantar_de_curso_scanner/app_links/app_links.dart';
import 'package:jantar_de_curso_scanner/pages/login.dart';
import 'package:jantar_de_curso_scanner/session/flows/base/session.dart';
import 'package:jantar_de_curso_scanner/session/flows/federated/session.dart';
import 'package:jantar_de_curso_scanner/session/logout/logout_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ScannerLogoutHandler extends LogoutHandler {
  ScannerLogoutHandler(this.context);

  final BuildContext context;

  @override
  FutureOr<void> closeFederatedSession(FederatedSession session) async {
    final appLinks = ScannerAppLinks();

    // await appLinks.logout.intercept((redirectUri) async {
    final logoutUri = session.credential.generateLogoutUrl(
      redirectUri: appLinks.logout.redirectUri,
    );

    if (logoutUri == null) {
      throw Exception('Failed to generate logout url');
    }

    await launchUrl(logoutUri);
    // });

    // await closeInAppWebView();
  }

  @override
  FutureOr<void> close(Session session) {
    Navigator.popUntil(context, (route) => false);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    return super.close(session);
  }
}
