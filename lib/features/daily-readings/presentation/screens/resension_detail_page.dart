import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../../presentation/widgets/custom_error.dart';
import '../../../../../presentation/themes/color_schemes.dart';
import '../../domain/entities/resension.dart';
import '../providers/detail_resension.dart';

class ReadingReviewDetailScreen extends ConsumerStatefulWidget {
  const ReadingReviewDetailScreen({super.key});

  @override
  ConsumerState<ReadingReviewDetailScreen> createState() =>
      _ReadingReviewDetailScreenState();
}

class _ReadingReviewDetailScreenState
    extends ConsumerState<ReadingReviewDetailScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewDetailState = ref.watch(selectedReviewProvider);

    // If no data available, show error or loading
    if (reviewDetailState.selectedReview == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Resensi Buku'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Tidak ada data resensi')),
      );
    }

    final currentReview = reviewDetailState.selectedReview!;
    final allReviews = reviewDetailState.allReviews;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildFullReviewContent(currentReview),
            16.height,
            _buildOtherReviewsList(currentReview, allReviews),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Resensi Buku',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black87),
          onPressed: () {
            // Implement share functionality
            _shareReview();
          },
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.black87),
          onPressed: () {
            // Implement bookmark functionality
            _bookmarkReview();
          },
        ),
      ],
    );
  }

  Widget _buildFullReviewContent(ReadingReview currentReview) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookHeader(currentReview),
          _buildReviewContent(currentReview),
          _buildReviewFooter(),
        ],
      ),
    );
  }

  Widget _buildBookHeader(ReadingReview currentReview) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookCoverLarge(currentReview),
              16.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentReview.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    8.height,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'oleh ${currentReview.author.name}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    12.height,
                    _buildBookMeta(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookCoverLarge(ReadingReview currentReview) {
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(currentReview.coverImageUrl),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            AppLogger.warning(
              'Failed to load image: ${currentReview.coverImageUrl}',
              tag: 'ReadingReviewDetail',
              error: exception,
            );
          },
        ),
      ),
      child:
          currentReview.coverImageUrl.isEmpty
              ? Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.book, size: 50, color: Colors.grey),
                ),
              )
              : null,
    );
  }

  Widget _buildBookMeta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetaRow(Icons.calendar_today, 'Dipublikasi: 15 Mar 2024'),
        4.height,
        _buildMetaRow(Icons.visibility, '1.2k pembaca'),
        4.height,
        _buildMetaRow(Icons.thumb_up, '89 suka'),
      ],
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        6.width,
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildReviewContent(ReadingReview currentReview) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          20.height,
          const Text(
            'Resensi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          12.height,
          Text(
            currentReview.content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
          24.height,
        ],
      ),
    );
  }

  Widget _buildReviewFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Divider(height: 1),
          16.height,
          Row(
            children: [
              _buildActionButton(
                Icons.thumb_up_outlined,
                'Suka',
                () => _likeReview(),
              ),
              12.width,
              _buildActionButton(
                Icons.comment_outlined,
                'Komentar',
                () => _showComments(),
              ),
              12.width,
              _buildActionButton(
                Icons.share_outlined,
                'Bagikan',
                () => _shareReview(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.grey[700]),
              6.width,
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherReviewsList(
    ReadingReview currentReview,
    List<ReadingReview> allReviews,
  ) {
    final otherReviews =
        allReviews.where((review) => review.id != currentReview.id).toList();

    if (otherReviews.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Resensi Lainnya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: otherReviews.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final review = otherReviews[index];
              return _buildOtherReviewItem(review);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOtherReviewItem(ReadingReview review) {
    return InkWell(
      onTap: () => _switchToReview(review),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(review.coverImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child:
                  review.coverImageUrl.isEmpty
                      ? Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(Icons.book, size: 24, color: Colors.grey),
                        ),
                      )
                      : null,
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
                  8.height,
                  Text(
                    review.content,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _switchToReview(ReadingReview review) {
    ref.read(selectedReviewProvider.notifier).selectReview(review);
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _likeReview() {
    // Implement like functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Resensi disukai!')));
  }

  void _shareReview() {
    // Implement share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Berbagi resensi...')));
  }

  void _bookmarkReview() {
    // Implement bookmark functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Resensi disimpan!')));
  }

  void _showComments() {
    // Implement comments functionality
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCommentsSheet(),
    );
  }

  Widget _buildCommentsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                12.height,
                const Text(
                  'Komentar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Expanded(
            child: Center(
              child: Text(
                'Belum ada komentar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
