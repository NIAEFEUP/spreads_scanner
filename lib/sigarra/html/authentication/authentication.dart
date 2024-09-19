import 'package:jantar_de_curso_scanner/sigarra/html/authentication/logged_in/logged_in.dart';
import 'package:jantar_de_curso_scanner/utils/lazy.dart';

class SigarraHtmlAuthentication {
  final _loggedIn = Lazy(() => const LoggedIn());
  LoggedIn get loggedIn => _loggedIn.value;
}
