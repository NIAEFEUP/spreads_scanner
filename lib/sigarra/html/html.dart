import 'package:jantar_de_curso_scanner/sigarra/html/authentication/authentication.dart';
import 'package:jantar_de_curso_scanner/utils/lazy.dart';

class SigarraHtml {
  final _authentication = Lazy(SigarraHtmlAuthentication.new);
  SigarraHtmlAuthentication get authentication => _authentication.value;
}