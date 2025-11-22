import 'dart:convert';
// TODO: consider supporting POST-based login and improved error mapping from API responses
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static const String baseLink = 'https://www.pqstec.com/InvoiceApps/Values/';
  static const String imageBaseLink = 'https://www.pqstec.com/InvoiceApps/';

  final http.Client client;
  String? token;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  void setToken(String? t) => token = t;

  Uri _uri(String endpoint) => Uri.parse(baseLink + endpoint);

  Future<Map<String, dynamic>> login({required String username, required String password, int comId = 1}) async {
    final uri = _uri('LogIn?UserName=${Uri.encodeComponent(username)}&Password=${Uri.encodeComponent(password)}&ComId=$comId');
    final resp = await client.get(uri);
    return _processResponse(resp);
  }

  Future<Map<String, dynamic>> getCustomerList({String searchQuery = '', int pageNo = 1, int pageSize = 20, String sortBy = 'Balance'}) async {
    final endpoint = 'GetCustomerList?searchquery=${Uri.encodeComponent(searchQuery)}&pageNo=$pageNo&pageSize=$pageSize&SortyBy=${Uri.encodeComponent(sortBy)}';
    final uri = _uri(endpoint);
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null && token!.isNotEmpty) {
      final authVal = token!.startsWith('Bearer ') ? token! : 'Bearer ${token!}';
      headers['Authorization'] = authVal;
    }
    final resp = await client.get(uri, headers: headers);
    return _processResponse(resp);
  }

  Map<String, dynamic> _processResponse(http.Response resp) {
    final code = resp.statusCode;
    try {
      final body = resp.body.isEmpty ? {} : json.decode(resp.body) as dynamic;
      if (code >= 200 && code < 300) {
        if (body is Map<String, dynamic>) return body;
        // body might be a List or other structure
        return {'data': body};
      }
      String message = 'Request failed with status $code';
      if (body is Map && body['message'] != null) message = body['message'].toString();
      if (body is String && body.isNotEmpty) message = body;
      // Log for debug
      // ignore: avoid_print
      print('API error ($code): $message');
      return {'error': true, 'message': message};
    } catch (e) {
      // ignore: avoid_print
      print('Failed to parse response: ${e.toString()} - raw body: ${resp.body}');
      return {'error': true, 'message': 'Failed to parse response: $e'};
    }
  }

  /// Build a safe, absolute image URL from a possibly-relative path.
  /// Returns null when [imagePath] is null or empty.
  static String? imageUrlFor(String? imagePath) {
    if (imagePath == null) return null;
    final trimmed = imagePath.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
    // normalize slashes and percent-encode path segments to handle spaces/special chars
    final base = imageBaseLink.endsWith('/') ? imageBaseLink : imageBaseLink + '/';
    final path = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    // Use Uri to encode the path portion safely
    final encodedPath = Uri(path: path).path; // encodes spaces and special characters
    final absolute = base + encodedPath;
    // If running on web, route through a local proxy to avoid CORS/Authorization preflight issues
    if (kIsWeb) {
      // Proxy is expected to run on localhost:3000 during development. The proxy will fetch the
      // remote image and return it with permissive CORS headers.
      final proxy = Uri.parse('http://localhost:3000/image-proxy');
      final proxied = proxy.replace(queryParameters: {'url': absolute});
      return proxied.toString();
    }
    return absolute;
  }
}
