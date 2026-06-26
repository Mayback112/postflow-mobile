import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/models/auth_models.dart';
import 'package:postflow/services/auth_token_storage.dart';

enum ApiEndpoint {
  authSign('/mobile/auth/sign'),
  authGoogle('/mobile/auth/google'),
  authRefresh('/mobile/auth/refresh'),
  authLogout('/mobile/auth/logout'),
  authMe('/mobile/auth/me'),
  workspaces('/mobile/workspaces'),
  socialAccounts('/mobile/social-accounts'),
  socialZernioConnect('/mobile/social-accounts/zernio/connect'),
  socialZernioConnectStatus('/mobile/social-accounts/zernio/connect-status'),
  socialZernioSync('/mobile/social-accounts/zernio/sync'),
  posts('/mobile/posts'),
  queuePreview('/mobile/queue/preview'),
  queueSlots('/mobile/queue/slots'),
  analyticsSummary('/mobile/analytics/summary'),
  analyticsBestTime('/mobile/analytics/best-time');

  const ApiEndpoint(this.path);

  final String path;
}

class Api {
  Api._();

  static final Uri baseUri = Uri.parse(_configuredBaseUrl);

  static String get _configuredBaseUrl {
    const dartDefineUrl = String.fromEnvironment('API_BASE_URL');
    if (dartDefineUrl.isNotEmpty) return dartDefineUrl;

    return 'https://nonrepudiable-richie-nonceremonious.ngrok-free.dev';
  }

  static const Map<ApiEndpoint, String> endpoints = {
    ApiEndpoint.authSign: '/mobile/auth/sign',
    ApiEndpoint.authGoogle: '/mobile/auth/google',
    ApiEndpoint.authRefresh: '/mobile/auth/refresh',
    ApiEndpoint.authLogout: '/mobile/auth/logout',
    ApiEndpoint.authMe: '/mobile/auth/me',
    ApiEndpoint.workspaces: '/mobile/workspaces',
    ApiEndpoint.socialAccounts: '/mobile/social-accounts',
    ApiEndpoint.socialZernioConnect: '/mobile/social-accounts/zernio/connect',
    ApiEndpoint.socialZernioConnectStatus:
        '/mobile/social-accounts/zernio/connect-status',
    ApiEndpoint.socialZernioSync: '/mobile/social-accounts/zernio/sync',
    ApiEndpoint.posts: '/mobile/posts',
    ApiEndpoint.queuePreview: '/mobile/queue/preview',
    ApiEndpoint.queueSlots: '/mobile/queue/slots',
    ApiEndpoint.analyticsSummary: '/mobile/analytics/summary',
    ApiEndpoint.analyticsBestTime: '/mobile/analytics/best-time',
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
}

class ApiClient {
  ApiClient({
    Dio? dio,
    Uri? baseUri,
    AuthTokenStorage? tokenStorage,
    bool enableAuthInterceptor = true,
  }) : _dio = dio ?? Dio(),
       _baseUri = baseUri ?? Api.baseUri {
    _dio.options = _dio.options.copyWith(
      baseUrl: _baseUri.toString(),
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (enableAuthInterceptor) {
      _dio.interceptors.add(
        BackendAuthInterceptor(
          dio: _dio,
          baseUri: _baseUri,
          tokenStorage: tokenStorage ?? AuthTokenStorage(),
        ),
      );
    }
  }

  final Dio _dio;
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

  Uri uriWithPath(String path, {Map<String, dynamic>? query}) {
    return _baseUri.replace(
      path: path,
      queryParameters: query?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Future<Map<String, dynamic>> postJson(
    ApiEndpoint endpoint,
    Map<String, dynamic>? body, {
    String? accessToken,
    bool skipAuth = false,
  }) async {
    return _requestJson(
      () => _dio.postUri(
        uri(endpoint),
        data: body,
        options: Options(
          headers: _headers(accessToken),
          extra: {'skipAuth': skipAuth},
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getJson(
    ApiEndpoint endpoint, {
    Map<String, dynamic>? query,
    String? accessToken,
    bool skipAuth = false,
  }) async {
    return _requestJson(
      () => _dio.getUri(
        uri(endpoint, query: query),
        options: Options(
          headers: _headers(accessToken),
          extra: {'skipAuth': skipAuth},
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> patchJson(
    ApiEndpoint endpoint,
    Map<String, dynamic>? body, {
    String? accessToken,
    bool skipAuth = false,
  }) async {
    return _requestJson(
      () => _dio.patchUri(
        uri(endpoint),
        data: body,
        options: Options(
          headers: _headers(accessToken),
          extra: {'skipAuth': skipAuth},
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> deleteJson(
    ApiEndpoint endpoint, {
    Map<String, dynamic>? query,
    String? accessToken,
    bool skipAuth = false,
  }) async {
    return _requestJson(
      () => _dio.deleteUri(
        uri(endpoint, query: query),
        options: Options(
          headers: _headers(accessToken),
          extra: {'skipAuth': skipAuth},
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> postJsonRaw(
    String path,
    Map<String, dynamic>? body, {
    String? accessToken,
    bool skipAuth = false,
  }) async {
    return _requestJson(
      () => _dio.postUri(
        uriWithPath(path),
        data: body,
        options: Options(
          headers: _headers(accessToken),
          extra: {'skipAuth': skipAuth},
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getJsonRaw(
    String path, {
    Map<String, dynamic>? query,
    String? accessToken,
    bool skipAuth = false,
  }) async {
    return _requestJson(
      () => _dio.getUri(
        uriWithPath(path, query: query),
        options: Options(
          headers: _headers(accessToken),
          extra: {'skipAuth': skipAuth},
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> patchJsonRaw(
    String path,
    Map<String, dynamic>? body, {
    String? accessToken,
    bool skipAuth = false,
  }) async {
    return _requestJson(
      () => _dio.patchUri(
        uriWithPath(path),
        data: body,
        options: Options(
          headers: _headers(accessToken),
          extra: {'skipAuth': skipAuth},
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> deleteJsonRaw(
    String path, {
    Map<String, dynamic>? query,
    String? accessToken,
    bool skipAuth = false,
  }) async {
    return _requestJson(
      () => _dio.deleteUri(
        uriWithPath(path, query: query),
        options: Options(
          headers: _headers(accessToken),
          extra: {'skipAuth': skipAuth},
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _requestJson(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      return _decodeResponse(response.data);
    } on DioException catch (error) {
      final response = error.response;
      final decodedBody = _decodeResponse(response?.data);
      if (kDebugMode && response != null) {
        debugPrint('API Error Body: ${response.data}');
      }
      throw ApiException(
        decodedBody['message'] as String? ?? 'Request failed',
        statusCode: response?.statusCode,
      );
    }
  }

  Map<String, String> _headers(String? accessToken) {
    return {
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  Map<String, dynamic> _decodeResponse(dynamic data) {
    if (data == null || data == '') return const {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw const ApiException('Unexpected API response');
  }

  void close() {
    _dio.close();
  }
}

class BackendAuthInterceptor extends QueuedInterceptor {
  BackendAuthInterceptor({
    required Dio dio,
    required Uri baseUri,
    required AuthTokenStorage tokenStorage,
  }) : _dio = dio,
       _baseUri = baseUri,
       _tokenStorage = tokenStorage,
       _refreshDio = Dio(
         BaseOptions(
           baseUrl: baseUri.toString(),
           connectTimeout: const Duration(seconds: 20),
           receiveTimeout: const Duration(seconds: 20),
           sendTimeout: const Duration(seconds: 20),
           headers: const {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
         ),
       );

  final Dio _dio;
  final Uri _baseUri;
  final AuthTokenStorage _tokenStorage;
  final Dio _refreshDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_skipsAuth(options) || options.headers.containsKey('Authorization')) {
      handler.next(options);
      return;
    }

    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestOptions = err.requestOptions;

    if (response?.statusCode != 401 ||
        _skipsAuth(requestOptions) ||
        requestOptions.extra['authRetry'] == true ||
        _isAuthEndpoint(requestOptions.path)) {
      handler.next(err);
      return;
    }

    try {
      final session = await _refreshSession();
      final retryOptions = _copyOptions(requestOptions)
        ..headers['Authorization'] = 'Bearer ${session.tokens.accessToken}'
        ..extra['authRetry'] = true;

      final retryResponse = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await _tokenStorage.clear();
      handler.next(err);
    }
  }

  bool _skipsAuth(RequestOptions options) => options.extra['skipAuth'] == true;

  bool _isAuthEndpoint(String path) {
    final requestPath = Uri.parse(path).path;
    return requestPath == ApiEndpoint.authRefresh.path ||
        requestPath == ApiEndpoint.authGoogle.path ||
        requestPath == ApiEndpoint.authLogout.path ||
        requestPath == ApiEndpoint.authSign.path;
  }

  Future<AuthSession> _refreshSession() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const ApiException('No refresh token is stored');
    }

    final response = await _refreshDio.postUri<Map<String, dynamic>>(
      _baseUri.replace(path: ApiEndpoint.authRefresh.path),
      data: {'refreshToken': refreshToken},
      options: Options(extra: const {'skipAuth': true}),
    );
    final session = AuthSession.fromJson(response.data ?? const {});
    await _tokenStorage.saveSession(session);
    return session;
  }

  RequestOptions _copyOptions(RequestOptions requestOptions) {
    return RequestOptions(
      path: requestOptions.path,
      method: requestOptions.method,
      baseUrl: requestOptions.baseUrl,
      queryParameters: Map<String, dynamic>.from(
        requestOptions.queryParameters,
      ),
      data: requestOptions.data,
      headers: Map<String, dynamic>.from(requestOptions.headers),
      extra: Map<String, dynamic>.from(requestOptions.extra),
      connectTimeout: requestOptions.connectTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      followRedirects: requestOptions.followRedirects,
      maxRedirects: requestOptions.maxRedirects,
      requestEncoder: requestOptions.requestEncoder,
      responseDecoder: requestOptions.responseDecoder,
      listFormat: requestOptions.listFormat,
    );
  }
}
