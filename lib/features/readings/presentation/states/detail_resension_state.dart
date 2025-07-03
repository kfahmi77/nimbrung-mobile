import '../../domain/entities/resension.dart';

class ReviewDetailState {
  final ReadingReview? selectedReview;
  final List<ReadingReview> allReviews;

  const ReviewDetailState({this.selectedReview, this.allReviews = const []});

  ReviewDetailState copyWith({
    ReadingReview? selectedReview,
    List<ReadingReview>? allReviews,
  }) {
    return ReviewDetailState(
      selectedReview: selectedReview ?? this.selectedReview,
      allReviews: allReviews ?? this.allReviews,
    );
  }
}
