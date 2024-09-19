import 'package:jantar_de_curso_scanner/sigarra/endpoints/api/authentication/login/login.dart';
import 'package:jantar_de_curso_scanner/utils/lazy.dart';

class SigarraApiAuthentication {
  final _login = Lazy(() => const Login());
  Login get login => _login.value;
}
