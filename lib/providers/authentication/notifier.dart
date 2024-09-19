import 'package:flutter/widgets.dart';
import 'package:jantar_de_curso_scanner/session/authentication_controller.dart';
import 'package:jantar_de_curso_scanner/session/flows/base/initiator.dart';
import 'package:jantar_de_curso_scanner/session/logout/scanner_logout_handler.dart';

class AuthenticationNotifier extends ValueNotifier<AuthenticationController?> {
  AuthenticationNotifier(this.context) : super(null);

  final BuildContext context;

  Future<void> login(SessionInitiator initiator) async {
    final request = await initiator.initiate();
    final session = await request.perform();

    value = AuthenticationController(
      session,
      // ignore: use_build_context_synchronously
      logoutHandler: ScannerLogoutHandler(context),
    );
  }
}
