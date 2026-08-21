import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl, this.token, http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  static const defaultBaseUrl = String.fromEnvironment(
    'STROT_API_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  final String baseUrl;
  final String? token;
  final http.Client _http;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<Map<String, dynamic>> get(String path) async {
    try {
      return _decode(
        await _http.get(Uri.parse('$baseUrl$path'), headers: _headers),
      );
    } on SocketException catch (_) {
      throw const NetworkUnavailableException();
    } on http.ClientException catch (_) {
      throw const NetworkUnavailableException();
    }
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async => _decode(
    await _http.post(
      Uri.parse('$baseUrl$path'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ),
  );

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async => _decode(
    await _http.put(
      Uri.parse('$baseUrl$path'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ),
  );

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async => _decode(
    await _http.patch(
      Uri.parse('$baseUrl$path'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ),
  );

  Future<Map<String, dynamic>> delete(String path) async => _decode(
    await _http.delete(Uri.parse('$baseUrl$path'), headers: _headers),
  );

  Future<Map<String, dynamic>> mutate(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final request = http.Request(method, Uri.parse('$baseUrl$path'))
        ..headers.addAll({..._headers, 'Content-Type': 'application/json'})
        ..body = jsonEncode(body);
      return _decode(await http.Response.fromStream(await _http.send(request)));
    } on SocketException catch (_) {
      throw const NetworkUnavailableException();
    } on http.ClientException catch (_) {
      throw const NetworkUnavailableException();
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        body['message'] as String? ?? 'The request could not be completed.',
        response.statusCode,
      );
    }
    return body;
  }
}

class NetworkUnavailableException implements Exception {
  const NetworkUnavailableException();
  @override
  String toString() => 'No network connection is currently available.';
}

class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);
  final String message;
  final int statusCode;
}
