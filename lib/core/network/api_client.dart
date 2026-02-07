import 'dart:math';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../services/app_logger.dart';

class ApiClient {
  static const _log = AppLogger('ApiClient');
  static const _maxRetries = 3;
  static const _retryableStatusCodes = {429, 500, 502, 503, 504};

  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: quranApiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // Logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _log.debug('${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _log.debug('${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _log.warning(
              '${error.type.name} ${error.requestOptions.uri}: ${error.message}');
          return handler.next(error);
        },
      ),
    );

    // Retry interceptor with exponential backoff
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            final retryCount =
                error.requestOptions.extra['retryCount'] as int? ?? 0;
            if (retryCount < _maxRetries) {
              final delay = _getRetryDelay(error, retryCount);
              _log.info(
                  'Retrying (${retryCount + 1}/$_maxRetries) after ${delay.inMilliseconds}ms: ${error.requestOptions.uri}');
              await Future.delayed(delay);

              error.requestOptions.extra['retryCount'] = retryCount + 1;
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                if (e is DioException) {
                  return handler.next(e);
                }
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  bool _shouldRetry(DioException error) {
    // Retry on timeouts
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return true;
    }
    // Retry on retryable HTTP status codes
    final statusCode = error.response?.statusCode;
    if (statusCode != null && _retryableStatusCodes.contains(statusCode)) {
      return true;
    }
    return false;
  }

  Duration _getRetryDelay(DioException error, int retryCount) {
    // Respect Retry-After header on 429
    if (error.response?.statusCode == 429) {
      final retryAfter = error.response?.headers.value('retry-after');
      if (retryAfter != null) {
        final seconds = int.tryParse(retryAfter);
        if (seconds != null) {
          return Duration(seconds: seconds.clamp(1, 30));
        }
      }
    }
    // Exponential backoff: 1s, 2s, 4s
    return Duration(seconds: pow(2, retryCount).toInt());
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }
}
