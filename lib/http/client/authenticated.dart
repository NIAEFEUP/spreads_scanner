import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart' show RetryClient;
import 'package:jantar_de_curso_scanner/sigarra/html/html.dart';
import 'package:jantar_de_curso_scanner/sigarra/options.dart';
import 'package:logger/logger.dart';
import 'package:jantar_de_curso_scanner/http/client/cookie.dart';
import 'package:jantar_de_curso_scanner/session/authentication_controller.dart';
import 'package:jantar_de_curso_scanner/session/exception.dart';
import 'package:jantar_de_curso_scanner/session/flows/base/session.dart';

class AuthenticatedClient extends http.BaseClient {
  AuthenticatedClient(
    this._inner, {
    required AuthenticationController controller,
  }) : _controller = controller;

  final http.Client _inner;
  final AuthenticationController _controller;

  /// Check if the user is still logged in,
  /// performing a health check on the user's personal page.
  Future<bool> _isUserLoggedIn(Session session) async {
    Logger().d('Checking if user is still logged in');

    final html = SigarraHtml();

    final response = await html.authentication.loggedIn.call(
      options: FacultyRequestOptions(
        faculty: session.mainFaculty,
        client: CookieClient(_inner, cookies: () => session.cookies),
      )
    );

    return response.success;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var snapshot = await _controller.snapshot;

    final client = RetryClient.withDelays(
      CookieClient(
        _inner,
        // Send the request with the cookies of the latest snapshot.
        cookies: () => snapshot.session.cookies,
      ),
      [Duration.zero],
      when: (response) async =>
          // We retry if the request is unauthorized
          response.statusCode == 403 &&
          // and, to be sure, if the user is not logged in SIGARRA.
          !await _isUserLoggedIn(snapshot.session),
      onRetry: (request, response, attempt) async {
        // When retrying, the previous session should be invalidated
        // and the session should be refreshed.
        await snapshot.invalidate();
        snapshot = await _controller.snapshot;
      },
    );

    final response = await client.send(request);

    // TODO(limwa): extract this logic to a method
    if (response.statusCode == 403 &&
        !await _isUserLoggedIn(snapshot.session)) {
      throw const AuthenticationException('User is not logged in SIGARRA');
    }

    return response;
  }

  @override
  void close() => _inner.close();
}
