import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_transport.dart' if (dart.library.io) 'api_transport_io.dart'
    as transport;

/// MAXKO public API client. Override with --dart-define=MAXKO_API_BASE=...
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  static const String baseUrl = String.fromEnvironment(
    'MAXKO_API_BASE',
    defaultValue: 'https://api.legiapos.vn/api',
  );

  final http.Client _client = transport.createApiHttpClient();
  String? accessToken;
  String? refreshToken;

  static String? resolveUrl(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }
    final raw = value.toString();
    if (raw.startsWith('http://') ||
        raw.startsWith('https://') ||
        raw.startsWith('data:')) {
      return raw;
    }
    final root = Uri.parse(baseUrl);
    final path = raw.startsWith('/') ? raw : '/$raw';
    return root.resolve(path).toString();
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) =>
      request('GET', path, query: query);

  Future<Map<String, dynamic>> post(String path,
          [Map<String, dynamic>? body]) =>
      request('POST', path, body: body);

  Future<Map<String, dynamic>> put(String path, [Map<String, dynamic>? body]) =>
      request('PUT', path, body: body);

  Future<Map<String, dynamic>> patch(String path,
          [Map<String, dynamic>? body]) =>
      request('PATCH', path, body: body);

  Future<Map<String, dynamic>> delete(String path) => request('DELETE', path);

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    bool retry = false,
  }) async {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final url = '${baseUrl.replaceFirst(RegExp(r'/$'), '')}/$normalizedPath';
    final parsed = Uri.parse(url);
    final uri = query == null ? parsed : parsed.replace(queryParameters: query);
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (accessToken != null && accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    late http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed =
          await _client.send(request).timeout(const Duration(seconds: 25));
      response = await http.Response.fromStream(streamed)
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw Exception('Kết nối máy chủ quá thời gian. Vui lòng thử lại.');
    } catch (error) {
      final errorText = error.toString();
      if (errorText.contains('Failed host lookup') ||
          errorText.contains('SocketException')) {
        throw Exception(
          'Không tìm thấy máy chủ MAXKO. Hãy kiểm tra kết nối Internet hoặc DNS rồi tải lại.',
        );
      }
      throw Exception('Không thể kết nối máy chủ MAXKO: $error');
    }

    final dynamic decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } catch (_) {
      throw Exception(
          'Máy chủ trả về dữ liệu không hợp lệ (${response.statusCode}).');
    }
    if (decoded is! Map) {
      return <String, dynamic>{
        'success': response.statusCode < 400,
        'data': decoded
      };
    }
    final result = Map<String, dynamic>.from(decoded);
    if (response.statusCode == 401 &&
        !retry &&
        refreshToken != null &&
        !path.startsWith('/auth/')) {
      try {
        final refreshed = await request('POST', '/auth/refresh',
            body: {'refreshToken': refreshToken}, retry: true);
        final authData = refreshed['data'];
        if (authData is Map && authData['accessToken'] != null) {
          accessToken = authData['accessToken'].toString();
          refreshToken = (authData['refreshToken'] ?? refreshToken).toString();
          return await request(method, path,
              query: query, body: body, retry: true);
        }
      } catch (_) {
        accessToken = null;
        refreshToken = null;
      }
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        result['success'] == false) {
      throw Exception((result['message'] ??
              result['error'] ??
              'Yêu cầu thất bại (${response.statusCode})')
          .toString());
    }
    return result;
  }

  static dynamic dataOf(Map<String, dynamic>? response) => response?['data'];

  static List<Map<String, dynamic>> listOf(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (value is Map && value['data'] is List) return listOf(value['data']);
    return const [];
  }
}
