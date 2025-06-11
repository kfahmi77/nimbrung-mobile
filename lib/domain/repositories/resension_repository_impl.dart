import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../data/datasources/resension_remote_data_source.dart';
import '../entities/resension.dart';
import 'resension_repository.dart';

class ReadingReviewRepositoryImpl implements ReadingReviewRepository {
  final ReadingReviewRemoteDataSource remoteDataSource;

  ReadingReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ReadingReview>>> getReadingReviews() async {
    AppLogger.info('Repository: Getting reading reviews', tag: 'Repository');

    try {
      final reviews = await remoteDataSource.getReadingReviews();

      AppLogger.info(
        'Repository: Successfully got ${reviews.length} reviews',
        tag: 'Repository',
      );

      return Right(reviews);
    } on NetworkException catch (e, stackTrace) {
      AppLogger.error(
        'Repository: Network error - ${e.message}',
        tag: 'Repository',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e, stackTrace) {
      AppLogger.error(
        'Repository: Server error - ${e.message}',
        tag: 'Repository',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(
        ServerFailure(
          message: e.message,
          code: e.code,
          statusCode: e.statusCode,
        ),
      );
    } on ClientException catch (e, stackTrace) {
      AppLogger.error(
        'Repository: Client error - ${e.message}',
        tag: 'Repository',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(
        ClientFailure(
          message: e.message,
          code: e.code,
          statusCode: e.statusCode,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Repository: Unexpected error',
        tag: 'Repository',
        error: e,
        stackTrace: stackTrace,
      );

      return const Left(UnknownFailure());
    }
  }
}
