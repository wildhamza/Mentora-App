import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mentora/core/constants/api_constants.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/core/utils/shared_prefs.dart';
import 'package:injectable/injectable.dart';

@singleton
class DioClient {
  late Dio _dio;
  final SharedPrefs _sharedPrefs;
  
  DioClient(this._sharedPrefs) {
    _init();
  }
  
  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          ApiConstants.contentType: ApiConstants.applicationJson,
        },
      ),
    );
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests if available
          final token = await _sharedPrefs.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers[ApiConstants.authorization] = '${ApiConstants.bearer}$token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == ApiConstants.unauthorized) {
            // Try to refresh token
            try {
              final refreshed = await _refreshToken();
              if (refreshed) {
                // Retry the original request
                final token = await _sharedPrefs.getAuthToken();
                error.requestOptions.headers[ApiConstants.authorization] = 
                    '${ApiConstants.bearer}$token';
                
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              }
            } catch (e) {
              debugPrint('Token refresh failed: $e');
              // Force logout
              await _sharedPrefs.clearAuthData();
              // Continue with error
            }
          }
          return handler.next(error);
        },
      ),
    );
    
    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }
  
  Future<bool> _refreshToken() async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        options: Options(headers: {
          ApiConstants.authorization: '${ApiConstants.bearer}${await _sharedPrefs.getAuthToken()}',
        }),
      );
      
      if (response.statusCode == 200 && response.data['token'] != null) {
        await _sharedPrefs.setAuthToken(response.data['token']);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }
  
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      throw Exception(AppConstants.errorGeneric);
    }
  }
  
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      throw Exception(AppConstants.errorGeneric);
    }
  }
  
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      throw Exception(AppConstants.errorGeneric);
    }
  }
  
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      throw Exception(AppConstants.errorGeneric);
    }
  }
  
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw Exception(AppConstants.errorTimeout);
      case DioExceptionType.badResponse:
        // Handle different status codes
        switch (error.response?.statusCode) {
          case ApiConstants.badRequest:
            final message = error.response?.data['message'] ?? AppConstants.errorGeneric;
            throw Exception(message);
          case ApiConstants.unauthorized:
            throw Exception(AppConstants.errorUnauthorized);
          case ApiConstants.forbidden:
            throw Exception(AppConstants.errorUnauthorized);
          case ApiConstants.notFound:
            throw Exception(AppConstants.errorNotFound);
          case ApiConstants.internalServerError:
            throw Exception(AppConstants.errorServer);
          default:
            throw Exception(AppConstants.errorGeneric);
        }
      case DioExceptionType.cancel:
        throw Exception('Request was cancelled');
      case DioExceptionType.connectionError:
        throw Exception(AppConstants.errorConnection);
      default:
        throw Exception(AppConstants.errorGeneric);
    }
  }
}
