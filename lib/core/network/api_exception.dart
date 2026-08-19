import 'package:dio/dio.dart';

/// Every BrokrsHouse API error response is `{ success: false, description, errors? }`.
/// This wraps that into a typed exception so UI code can just read `.description`.
class ApiException implements Exception {
  ApiException({required this.statusCode, required this.description, this.errors});

  final int? statusCode;
  final String description;
  final List<dynamic>? errors;

  factory ApiException.fromDioException(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['description'] is String) {
      return ApiException(
        statusCode: e.response?.statusCode,
        description: data['description'] as String,
        errors: data['errors'] as List<dynamic>?,
      );
    }

    return ApiException(
      statusCode: e.response?.statusCode,
      description: switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'The connection timed out. Please check your internet and try again.',
        DioExceptionType.connectionError => 'Could not reach the server. Please try again.',
        _ => 'Something went wrong. Please try again.',
      },
    );
  }

  @override
  String toString() => description;
}
