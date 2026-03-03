import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PerformanceInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) {
    options.extra['startTime'] = DateTime.now();
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    final startTime = response.requestOptions.extra['startTime'];
    if (startTime != null) {
      final duration =
          DateTime.now().difference(startTime).inMilliseconds;

      final path = response.requestOptions.path;
      final query = response.requestOptions.queryParameters;

      debugPrint(
          "[API] SUCCESS $path $query → ${duration}ms");
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    final startTime = err.requestOptions.extra['startTime'];
    final path = err.requestOptions.path;
    final query = err.requestOptions.queryParameters;

    if (CancelToken.isCancel(err)) {
      debugPrint("[API] CANCELLED $path $query");
    } else if (startTime != null) {
      final duration =
          DateTime.now().difference(startTime).inMilliseconds;

      debugPrint(
          "[API] ERROR $path $query → ${duration}ms");
    }

    super.onError(err, handler);
  }
}