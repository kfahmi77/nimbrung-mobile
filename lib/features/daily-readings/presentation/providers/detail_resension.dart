import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/resension.dart';
import '../states/detail_resension_state.dart';

class ReviewDetailNotifier extends StateNotifier<ReviewDetailState> {
  ReviewDetailNotifier() : super(const ReviewDetailState());

  void setReviewData(
    ReadingReview selectedReview,
    List<ReadingReview> allReviews,
  ) {
    state = ReviewDetailState(
      selectedReview: selectedReview,
      allReviews: allReviews,
    );
  }

  void selectReview(ReadingReview review) {
    state = state.copyWith(selectedReview: review);
  }

  void clearData() {
    state = const ReviewDetailState();
  }
}

// Provider for the review detail state
final selectedReviewProvider =
    StateNotifierProvider<ReviewDetailNotifier, ReviewDetailState>(
      (ref) => ReviewDetailNotifier(),
    );
