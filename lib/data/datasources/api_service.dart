import 'package:dio/dio.dart';
import '../../core/constants.dart';

class ApiService {
  final Dio _dio;
  
  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.contentType = Headers.jsonContentType;
    _dio.options.responseType = ResponseType.json;
    
    // Add request interceptor for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from secure storage or shared preferences
          final token = await _getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Handle error globally
          if (error.response?.statusCode == 401) {
            // Token expired or invalid, logout user
            // Navigate to login
          }
          return handler.next(error);
        },
      ),
    );
  }
  
  Future<String?> _getToken() async {
    // In a real app, get token from secure storage
    // For this example, we'll simulate with a fake token
    return 'fake_token';
  }
  
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleError(e);
    } catch (e) {
      throw Exception(ErrorMessages.unknownError);
    }
  }
  
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleError(e);
    } catch (e) {
      throw Exception(ErrorMessages.unknownError);
    }
  }
  
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleError(e);
    } catch (e) {
      throw Exception(ErrorMessages.unknownError);
    }
  }
  
  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleError(e);
    } catch (e) {
      throw Exception(ErrorMessages.unknownError);
    }
  }
  
  dynamic _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Unexpected status code: ${response.statusCode}',
      );
    }
  }
  
  Never _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw Exception(ErrorMessages.networkError);
    } else if (e.response != null) {
      final errorMessage = e.response?.data?['message'] ?? ErrorMessages.serverError;
      throw Exception(errorMessage);
    } else {
      throw Exception(ErrorMessages.networkError);
    }
  }
}
