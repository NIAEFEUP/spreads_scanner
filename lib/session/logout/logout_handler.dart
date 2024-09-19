import 'dart:async';

import 'package:jantar_de_curso_scanner/session/flows/base/session.dart';
import 'package:jantar_de_curso_scanner/session/flows/federated/session.dart';

abstract class LogoutHandler {
  FutureOr<void> closeFederatedSession(FederatedSession session) {}

  FutureOr<void> close(Session session) {
    if (session is FederatedSession) {
      return closeFederatedSession(session);
    } else {
      throw Exception('Unknown session type');
    }
  }
}
