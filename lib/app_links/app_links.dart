import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:jantar_de_curso_scanner/utils/uri.dart';

final _authUri = Uri(scheme: 'pt.niaefeup.validation-scanner', host: 'auth');

class ScannerAppLinks {
  final login = _AuthenticationAppLink(
    redirectUri: _authUri.replace(path: '/login'),
  );

  final logout = _AuthenticationAppLink(
    redirectUri: _authUri.replace(path: '/logout'),
  );
}

class _AuthenticationAppLink {
  _AuthenticationAppLink({required this.redirectUri});

  final AppLinks _appLinks = AppLinks();
  final Uri redirectUri;

  Future<Uri> intercept(
    FutureOr<void> Function(Uri redirectUri) callback,
  ) async {
    final interceptedUri = _appLinks.uriLinkStream
        .firstWhere((uri) => redirectUri == uri.stripQueryComponent());

    await callback(redirectUri);
    final data = await interceptedUri;
    return data;
  }
}
