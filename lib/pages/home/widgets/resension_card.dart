import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';

import '../../../themes/color_schemes.dart';
import '../../../models/resension_model.dart';
import '../../../providers/resension_provider.dart';

class ResensionCard extends ConsumerStatefulWidget {
  const ResensionCard({super.key});

  @override
  ConsumerState<ResensionCard> createState() => _ResensionCardState();
}

class _ResensionCardState extends ConsumerState<ResensionCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final readingReviewsAsync = ref.watch(readingReviewsProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resensi Buku',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          16.height,
          readingReviewsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (ReadingReviewResponse response) {
              final bookReviews = response.data;

              if (bookReviews.isEmpty) {
                return const Center(child: Text('Tidak ada resensi buku.'));
              }

              return Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: bookReviews.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        final review = bookReviews[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(
                                  red: 0.9,
                                  green: 0.9,
                                  blue: 0.9,
                                ),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Book cover
                              Container(
                                width: 80,
                                height: 160,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(review.coverImageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // Book details
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      4.height,
                                      Text(
                                        review.author.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Indicator
                  12.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(
                      bookReviews.length,
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
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
