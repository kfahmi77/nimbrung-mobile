import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constant.dart';
import '../data/datasources/resension_remote_data_source.dart';
import '../domain/entities/resension.dart';
import '../domain/repositories/resension_repository_impl.dart';
import '../domain/usecases/get_resension.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConstant.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );
});

final readingReviewRemoteDataSourceProvider =
    Provider<ReadingReviewRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return ReadingReviewRemoteDataSourceImpl(dio);
    });

final readingReviewRepositoryProvider = Provider<ReadingReviewRepositoryImpl>((
  ref,
) {
  final remoteDataSource = ref.watch(readingReviewRemoteDataSourceProvider);
  return ReadingReviewRepositoryImpl(remoteDataSource);
});

final getReadingReviewsUseCaseProvider = Provider<GetReadingReviews>((ref) {
  final repository = ref.watch(readingReviewRepositoryProvider);
  return GetReadingReviews(repository);
});

final readingReviewsProvider = FutureProvider.autoDispose<List<ReadingReview>>((
  ref,
) async {
  final useCase = ref.watch(getReadingReviewsUseCaseProvider);
  final result = await useCase();

  return result.fold((failure) => throw failure, (reviews) => reviews);
});
