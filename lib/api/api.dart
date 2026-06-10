import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:postflow/api/api_exception.dart';

enum ApiEndpoint {
  authSign('/mobile/auth/sign'),
  authTest('/mobile/auth/test'),
  authRefresh('/mobile/auth/refresh');

  const ApiEndpoint(this.path);

  final String path;
}

class Api {
  Api._();

  static final Uri baseUri = Uri.parse(
    const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:4000',
    ),
  );

  static const Map<ApiEndpoint, String> endpoints = {
    ApiEndpoint.authSign: '/mobile/auth/sign',
    ApiEndpoint.authTest: '/mobile/auth/test',
    ApiEndpoint.authRefresh: '/mobile/auth/refresh',
  };

  static Uri uri(ApiEndpoint endpoint, {Map<String, dynamic>? query}) {
    final endpointPath = endpoints[endpoint] ?? endpoint.path;
    return baseUri.replace(
      path: endpointPath,
      queryParameters: query?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  static Map<String, String> jsonHeaders({String? accessToken}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }
}

class ApiClient {
  ApiClient({http.Client? client, Uri? baseUri})
    : _client = client ?? http.Client(),
      _baseUri = baseUri ?? Api.baseUri;

  final http.Client _client;
  final Uri _baseUri;

  Uri uri(ApiEndpoint endpoint, {Map<String, dynamic>? query}) {
    final endpointPath = Api.endpoints[endpoint] ?? endpoint.path;
    return _baseUri.replace(
      path: endpointPath,
      queryParameters: query?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Future<Map<String, dynamic>> postJson(
    ApiEndpoint endpoint,
    Map<String, dynamic>? body, {
    String? accessToken,
  }) async {
    final requestUri = uri(endpoint);
    if (kDebugMode) {
      debugPrint('API POST $requestUri');
    }

    final response = await _postWithLocalEmulatorFallback(
      requestUri,
      body,
      accessToken: accessToken,
    );

    if (kDebugMode) {
      debugPrint(
        'API ${response.statusCode} ${response.request?.url ?? requestUri}',
      );
    }

    final decodedBody = _decodeResponse(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        decodedBody['message'] as String? ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }

    return decodedBody;
  }

  Future<http.Response> _postWithLocalEmulatorFallback(
    Uri requestUri,
    Map<String, dynamic>? body, {
    String? accessToken,
  }) async {
    try {
      return await _post(requestUri, body, accessToken: accessToken);
    } on TimeoutException {
      final fallbackUri = _localAndroidFallbackUri(requestUri);
      if (fallbackUri == null) rethrow;

      if (kDebugMode) {
        debugPrint('API retry $fallbackUri');
      }
      return _post(fallbackUri, body, accessToken: accessToken);
    }
  }

  Future<http.Response> _post(
    Uri requestUri,
    Map<String, dynamic>? body, {
    String? accessToken,
  }) {
    return _client
        .post(
          requestUri,
          headers: Api.jsonHeaders(accessToken: accessToken),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 8));
  }

  Uri? _localAndroidFallbackUri(Uri requestUri) {
    if (requestUri.scheme != 'http' ||
        requestUri.host != '10.0.2.2' ||
        requestUri.port != 4000) {
      return null;
    }

    return requestUri.replace(host: '10.0.3.2');
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.isEmpty) return const {};

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;

    throw const ApiException('Unexpected API response');
  }

  void close() {
    _client.close();
  }
}
