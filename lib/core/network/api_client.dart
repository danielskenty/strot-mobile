import 'dart:convert';
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

  Future<Map<String, dynamic>> get(String path) async =>
      _decode(await _http.get(Uri.parse('$baseUrl$path'), headers: _headers));

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

class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);
  final String message;
  final int statusCode;
}
