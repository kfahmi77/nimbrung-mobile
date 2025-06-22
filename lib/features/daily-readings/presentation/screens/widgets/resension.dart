import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../../presentation/routes/route_name.dart';
import '../../../../../presentation/widgets/custom_error.dart';
import '../../../domain/entities/resension.dart';
import '../../providers/detail_resension.dart';
import '../../providers/resension_provider.dart';
import '../../../../../presentation/themes/color_schemes.dart';

class ResensionCard extends ConsumerStatefulWidget {
  const ResensionCard({super.key});

  @override
  ConsumerState<ResensionCard> createState() => _ResensionCardState();
}

class _ResensionCardState extends ConsumerState<ResensionCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readingReviewsAsync = ref.watch(readingReviewsProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resensi Buku',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all reviews page if needed
                  _navigateToAllReviews();
                },
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          16.height,
          readingReviewsAsync.when(
            loading: () {
              AppLogger.info('Loading reading reviews', tag: 'ResensionCard');
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stackTrace) {
              AppLogger.error(
                'Error displaying reading reviews',
                tag: 'ResensionCard',
                error: error,
                stackTrace: stackTrace,
              );

              // Option 1: Using the provider-aware widget
              return CustomErrorWidgetWithProvider(
                error: error,
                provider: readingReviewsProvider,
                logTag: 'ResensionCard',
                customMessage: 'Gagal memuat resensi buku',
                customDetails:
                    'Terjadi kesalahan saat memuat daftar resensi buku.',
              );

              // Option 2: Using the helper extension (alternative)
              // return error.toProviderErrorWidget(
              //   provider: readingReviewsProvider,
              //   ref: ref,
              //   logTag: 'ResensionCard',
              //   customMessage: 'Gagal memuat resensi buku',
              // );
            },
            data: (reviews) {
              AppLogger.info(
                'Successfully loaded ${reviews.length} reviews',
                tag: 'ResensionCard',
              );

              if (reviews.isEmpty) {
                return const Center(child: Text('Tidak ada resensi buku.'));
              }

              return _buildReviewsList(reviews);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(List<ReadingReview> reviews) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: reviews.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final review = reviews[index];
              return _buildReviewCard(review, reviews);
            },
          ),
        ),
        12.height,
        _buildPageIndicator(reviews.length),
      ],
    );
  }

  Widget _buildReviewCard(
    ReadingReview review,
    List<ReadingReview> allReviews,
  ) {
    return GestureDetector(
      onTap: () => _navigateToReviewDetail(review, allReviews),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookCover(review.coverImageUrl),
            _buildBookDetails(review),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCover(String imageUrl) {
    return Container(
      width: 80,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            AppLogger.warning(
              'Failed to load image: $imageUrl',
              tag: 'ResensionCard',
              error: exception,
            );
          },
        ),
      ),
      child:
          imageUrl.isEmpty
              ? const Center(
                child: Icon(Icons.book, size: 40, color: Colors.grey),
              )
              : null,
    );
  }

  Widget _buildBookDetails(ReadingReview review) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            4.height,
            Text(
              review.author.name,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            12.height,
            Text(
              review.content,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.justify,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Baca Selengkapnya',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int length) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                _currentPage == index
                    ? AppColors.primary
                    : Colors.grey.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  void _navigateToReviewDetail(
    ReadingReview review,
    List<ReadingReview> allReviews,
  ) {
    // Store the data in a provider or pass via extra
    ref.read(selectedReviewProvider.notifier).setReviewData(review, allReviews);

    context.pushNamed(
      RouteNames.detailReading,
      pathParameters: {'reviewId': review.id.toString()},
    );
  }

  void _navigateToAllReviews() {
    // Implement navigation to all reviews page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigasi ke semua resensi')));
  }
}
