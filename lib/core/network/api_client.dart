import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/env.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// Thin wrapper around Dio configured for the BrokrsHouse API:
///  - attaches `Authorization: Bearer <accessToken>` to every request
///  - on a 401, transparently refreshes the token pair via
///    `POST /api/auth/refresh-token` and retries the original request once
///  - concurrent 401s share a single in-flight refresh (no thundering herd)
///  - on refresh failure, clears stored tokens so the app's auth-state
///    listener can redirect to login
class ApiClient {
  ApiClient(this._tokenStorage) : dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl, connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 15))) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final isAuthRoute = error.requestOptions.path.startsWith('/auth/');
          final alreadyRetried = error.requestOptions.extra['retried'] == true;

          if (error.response?.statusCode == 401 && !isAuthRoute && !alreadyRetried) {
            try {
              await _refreshTokens();
              final retryOptions = error.requestOptions..extra['retried'] = true;
              final newToken = await _tokenStorage.readAccessToken();
              retryOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await dio.fetch(retryOptions);
              return handler.resolve(response);
            } catch (_) {
              await _tokenStorage.clear();
              onSessionExpired?.call();
            }
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(requestBody: true, responseBody: true, error: true));
    }
  }

  final Dio dio;
  final TokenStorage _tokenStorage;

  /// Fired once when a refresh attempt fails (refresh token itself expired
  /// or revoked) — the app wires this to force navigation back to login.
  VoidCallback? onSessionExpired;

  Completer<void>? _refreshCompleter;

  Future<void> _refreshTokens() {
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<void>();
    _refreshCompleter = completer;

    () async {
      try {
        final refreshToken = await _tokenStorage.readRefreshToken();
        if (refreshToken == null) {
          throw ApiException(statusCode: 401, description: 'No refresh token available');
        }
        final response = await dio.post('/auth/refresh-token', data: {'refreshToken': refreshToken});
        final data = response.data['data'] as Map<String, dynamic>;
        await _tokenStorage.saveTokens(accessToken: data['accessToken'] as String, refreshToken: data['refreshToken'] as String);
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      } finally {
        _refreshCompleter = null;
      }
    }();

    return completer.future;
  }

  /// Unwraps `{ success, description, data }` and returns `data`, throwing
  /// [ApiException] for both transport errors and non-2xx API errors.
  Future<T> unwrap<T>(Future<Response> Function() request) async {
    try {
      final response = await request();
      final body = response.data as Map<String, dynamic>;
      return body['data'] as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Same as [unwrap] but for endpoints that return no `data` payload —
  /// just confirms success and gives you the `description` message.
  Future<String> unwrapMessage(Future<Response> Function() request) async {
    try {
      final response = await request();
      final body = response.data as Map<String, dynamic>;
      return body['description'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
