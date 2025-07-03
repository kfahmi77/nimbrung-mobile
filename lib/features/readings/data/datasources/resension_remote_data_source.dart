import 'package:dio/dio.dart';
import 'package:nimbrung_mobile/core/constants/api_constant.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../models/resension_model.dart';

abstract class ReadingReviewRemoteDataSource {
  Future<List<ReadingReviewModel>> getReadingReviews();
}

class ReadingReviewRemoteDataSourceImpl
    implements ReadingReviewRemoteDataSource {
  final Dio dio;

  ReadingReviewRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ReadingReviewModel>> getReadingReviews() async {
    AppLogger.info(
      'Fetching reading reviews from API',
      tag: 'RemoteDataSource',
    );

    try {
      final response = await dio.get(ApiConstant.readDailyResension);

      AppLogger.debug(
        'API Response: ${response.statusCode}',
        tag: 'RemoteDataSource',
      );

      final responseModel = ReadingReviewResponse.fromJson(response.data);

      if (!responseModel.success) {
        final error = responseModel.error;
        if (error != null) {
          AppLogger.error(
            'Server returned error: ${error.message}',
            tag: 'RemoteDataSource',
          );

          if (responseModel.statusCode >= 500) {
            throw ServerException(
              message: error.message,
              code: error.code,
              statusCode: responseModel.statusCode,
            );
          } else {
            throw ClientException(
              message: error.message,
              code: error.code,
              statusCode: responseModel.statusCode,
            );
          }
        }
      }

      if (responseModel.data == null) {
        throw const ServerException(
          message: 'No data received from server',
          code: 'NO_DATA',
          statusCode: 200,
        );
      }

      AppLogger.info(
        'Successfully fetched ${responseModel.data!.length} reviews',
        tag: 'RemoteDataSource',
      );

      return responseModel.data!;
    } on DioException catch (e, stackTrace) {
      AppLogger.error(
        'Dio error occurred',
        tag: 'RemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException(message: 'Connection timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(message: 'No internet connection');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode ?? 0;
        final responseData = e.response!.data;

        if (responseData is Map<String, dynamic>) {
          final error = responseData['error'];
          if (error != null && error is Map<String, dynamic>) {
            final errorMessage = error['message'] ?? 'Unknown server error';
            final errorCode = error['code'] ?? 'SERVER_ERROR';

            if (statusCode >= 500) {
              throw ServerException(
                message: errorMessage,
                code: errorCode,
                statusCode: statusCode,
              );
            } else {
              throw ClientException(
                message: errorMessage,
                code: errorCode,
                statusCode: statusCode,
              );
            }
          }
        }

        if (statusCode >= 500) {
          throw ServerException(
            message: 'Server error occurred',
            code: 'SERVER_ERROR',
            statusCode: statusCode,
          );
        } else {
          throw ClientException(
            message: 'Client error occurred',
            code: 'CLIENT_ERROR',
            statusCode: statusCode,
          );
        }
      }

      throw const NetworkException(message: 'Network error occurred');
    } catch (e, stackTrace) {
      if (e is ServerException ||
          e is ClientException ||
          e is NetworkException) {
        rethrow;
      }

      AppLogger.error(
        'Unexpected error in remote data source',
        tag: 'RemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );

      throw const ServerException(
        message: 'An unexpected error occurred',
        code: 'UNKNOWN_ERROR',
        statusCode: 0,
      );
    }
  }
}
