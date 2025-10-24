import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class Urls {
  // create un metodo postUrl que reciba un String path y retorne la url completa
  static Future<Map<String, dynamic>> postUrl(
    String path,
    Map<String, String> body,
    Map<String, String> headers,
  ) async {
    const String baseUrl = 'http://localhost:3000/api';
    final String url = '$baseUrl$path';
    log('$url', name: 'URL completa POST');
    //completar el body con try catch
    log('$body', name: 'Body de la peticion POST');
    try {
      //realizar la peticion post
      http.Response response = await http
          .post(Uri.parse(url), body: jsonEncode(body), headers: headers)
          .timeout(const Duration(seconds: 10));
      log(
        '${response.statusCode} - ${response.body}',
        name: 'Respuesta de la peticion',
      );
      return jsonDecode(response.body);
    } catch (e) {
      log('$e', name: 'Error en la peticion POST');
    }
    return {'status': false, 'message': 'Error en la peticion POST'};
  }

  /// create un metodo getUrl que reciba un String path y retorne la url completa
  static Future<Map<String, dynamic>> getUrl(
    String path,
    Map<String, String> headers,
  ) async {
    const String baseUrl = 'http://localhost:3000/api';
    final String url = '$baseUrl$path';
    log('$url', name: 'URL completa GET');
    //completar el body con try catch
    try {
      //realizar la peticion get
      http.Response response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));

      log(
        '${response.statusCode} - ${response.body}',
        name: 'Respuesta de la peticion GET',
      );

      return jsonDecode(response.body);
    } catch (e) {
      log('$e', name: 'Error en la peticion GET');
    }
    return {'status': false, 'message': 'Error en la peticion GET'};
  }
}
