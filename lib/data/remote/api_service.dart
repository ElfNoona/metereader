import 'dart:io';
import 'package:dio/dio.dart';
import '../../main.dart';
import '../local/storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
      ),
    );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: _onRequestInterceptor,
        onError: _onErrorInterceptor,
      ),
    );
  }

  /// Appends standard JWT access tokens only if the request is targeting our own backend.
  Future<void> _onRequestInterceptor(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isInternalRequest = options.path.startsWith(_baseUrl) || !options.path.startsWith('http');
    
    if (isInternalRequest) {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    return handler.next(options);
  }

  /// Intercepts 401 token expiration errors strictly for our internal Node.js backend.
  Future<void> _onErrorInterceptor(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isInternalRequest = err.requestOptions.path.startsWith(_baseUrl) || !err.requestOptions.path.startsWith('http');

    // Only attempt token refresh if it's a 401 error originating from our own server
    if (err.response?.statusCode != 401 || !isInternalRequest) {
      return handler.next(err);
    }

    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _clearLocalSession();
        return handler.next(err);
      }

      final refreshResponse = await Dio(BaseOptions(baseUrl: _baseUrl)).post(
        '/auth/refresh',
        data: {'token': refreshToken},
      );

      if (refreshResponse.statusCode == 200 && refreshResponse.data['success'] == true) {
        final newAccessToken = refreshResponse.data['accessToken'];
        final newRefreshToken = refreshResponse.data['refreshToken'];
        final userId = await StorageService.getUserId() ?? '';

        await StorageService.startSession(newAccessToken, newRefreshToken, userId);

        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _dio.fetch(requestOptions);
        return handler.resolve(retryResponse);
      }
    } catch (refreshError) {
      _clearLocalSession();
    }

    return handler.next(err);
  }

  void _clearLocalSession() {
    StorageService.clearSession();
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> downloadBytes(String path) async {
    try {
      return await _dio.get(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> uploadFile(String path, String localFilePath, Map<String, dynamic> additionalFields) async {
    try {
      final file = File(localFilePath);
      if (!await file.exists()) throw Exception("Local file not found.");

      final formData = FormData.fromMap({
        ...additionalFields,
        'image': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      return await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Sends the captured cropped image directly and synchronously to company's hosted ML microserver.
  /// Bypasses Node.js JWT parameters since the path uses an external absolute URL.
  Future<Response> uploadImageToCompanyML(String mlServerUrl, String localFilePath) async {
    try {
      final file = File(localFilePath);
      if (!await file.exists()) throw Exception("Cropped meter image file not found.");

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      // Directly posting to the company's full URL. Dio automatically ignores the 
      // internal base URL when a request path starts with "http://" or "https://".
      return await _dio.post(
        mlServerUrl,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException err) {
    final errorMessage = err.response?.data['error'] ?? err.message ?? 'Network request failed.';
    return Exception(errorMessage);
  }
}
