import 'package:jantar_de_curso_scanner/sigarra/endpoints/oidc/token/token.dart';
import 'package:jantar_de_curso_scanner/utils/lazy.dart';

class SigarraOidc {
  final _token = Lazy(Token.new);
  Token get token => _token.value;
}
