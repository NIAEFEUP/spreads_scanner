import 'package:jantar_de_curso_scanner/http/utils.dart';
import 'package:jantar_de_curso_scanner/sigarra/endpoints/oidc/token/response.dart';
import 'package:jantar_de_curso_scanner/sigarra/options.dart';

class Token {
  const Token();

  /// Returns the cookies for SIGARRA using the OIDC token.
  ///
  /// The client must be authorized to make this request.
  Future<TokenResponse> call({
    BaseRequestOptions? options,
  }) async {
    options = options ?? BaseRequestOptions();

    final tokenUrl = options.baseUrl.resolve('auth/oidc/token');
    final response = await options.client.get(
      tokenUrl,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return TokenSuccessfulResponse(cookies: extractCookies(response));
    }

    return const TokenFailedResponse();
  }
}
