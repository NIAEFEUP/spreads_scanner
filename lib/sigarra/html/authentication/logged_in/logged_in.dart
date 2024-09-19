import 'package:http/http.dart' as http;
import 'package:jantar_de_curso_scanner/sigarra/options.dart';
import 'package:jantar_de_curso_scanner/sigarra/response.dart';

class LoggedIn {
  const LoggedIn();

  Future<SigarraResponse> call({
    FacultyRequestOptions? options,
  }) async {
    options = options ?? FacultyRequestOptions();

    final loginUrl = options.baseUrl.resolve('web_page.inicial');

    final response = await options.client.get(loginUrl);

    return _parse(response);
  }

  Future<SigarraResponse> _parse(http.Response response) async {
    final body = response.body;

    if (body.contains('<div class="autenticacao autenticado">')) {
      return const SigarraResponse(success: true);
    }

    return const SigarraResponse(success: false);
  }
}
