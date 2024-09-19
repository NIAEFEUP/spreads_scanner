import 'dart:async';

import 'package:jantar_de_curso_scanner/app_links/app_links.dart';
import 'package:jantar_de_curso_scanner/session/flows/base/session.dart';
import 'package:jantar_de_curso_scanner/session/flows/federated/session.dart';
import 'package:jantar_de_curso_scanner/session/logout/logout_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ScannerLogoutHandler extends LogoutHandler {
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
    // NavigationService.logoutAndPopHistory();
    return super.close(session);
  }
}
