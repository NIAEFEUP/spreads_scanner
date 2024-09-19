import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jantar_de_curso_scanner/session/authentication_controller.dart';
import 'package:jantar_de_curso_scanner/session/flows/base/initiator.dart';
import 'package:jantar_de_curso_scanner/session/logout/scanner_logout_handler.dart';

class AuthenticationNotifier extends ValueNotifier<AuthenticationController?> {
  AuthenticationNotifier() : super(null);

  Future<void> login(SessionInitiator initiator) async {
    final request = await initiator.initiate();
    final session = await request.perform();

    value = AuthenticationController(session, logoutHandler: ScannerLogoutHandler());
  }
}