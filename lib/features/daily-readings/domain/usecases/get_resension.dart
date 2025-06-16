import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../entities/resension.dart';
import '../repositories/resension_repository.dart';

class GetReadingReviews {
  final ReadingReviewRepository repository;

  GetReadingReviews(this.repository);

  Future<Either<Failure, List<ReadingReview>>> call() async {
    AppLogger.info('Fetching reading reviews', tag: 'GetReadingReviews');

    try {
      final result = await repository.getReadingReviews();

      return result.fold(
        (failure) {
          AppLogger.error(
            'Failed to get reading reviews: ${failure.message}',
            tag: 'GetReadingReviews',
          );
          return Left(failure);
        },
        (reviews) {
          AppLogger.info(
            'Successfully fetched ${reviews.length} reading reviews',
            tag: 'GetReadingReviews',
          );
          return Right(reviews);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetReadingReviews',
        tag: 'GetReadingReviews',
        error: e,
        stackTrace: stackTrace,
      );
      return const Left(UnknownFailure());
    }
  }
}
