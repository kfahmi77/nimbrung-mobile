import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/resension.dart';

abstract class ReadingReviewRepository {
  Future<Either<Failure, List<ReadingReview>>> getReadingReviews();
}
