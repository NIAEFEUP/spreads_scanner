import 'package:jantar_de_curso_scanner/sigarra/endpoints/api/authentication/authentication.dart';
import 'package:jantar_de_curso_scanner/utils/lazy.dart';

class SigarraApi {
  final _authentication = Lazy(SigarraApiAuthentication.new);
  SigarraApiAuthentication get authentication => _authentication.value;
}
