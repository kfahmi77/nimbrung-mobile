import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/presentation/extension/snackbar_extension.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../../presentation/themes/color_schemes.dart';
import '../../../../presentation/widgets/custom_snackbar.dart';
import '../../../discussions/comment.dart';
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
  bool _isReadingMode = false;
  double _fontSize = 16.0;
  double _scrollProgress = 0.0;
  bool _showOtherReviews = true;

  // Comment system
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  final Set<int> _expandedComments = <int>{};

  // Sample comments data
  final List<Comment> _comments = [
    Comment(
      userName: 'Dr. Sarah Chen',
      userImageUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
      timeAgo: '2 jam yang lalu',
      text:
          'Resensi yang sangat mendalam! Saya setuju dengan analisis tentang character development di buku ini.',
      isExpert: true,
      likesCount: 12,
      repliesCount: 2,
      replies: [
        Comment(
          userName: 'Ahmad Rizki',
          userImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
          timeAgo: '1 jam yang lalu',
          text: 'Betul sekali, Dr. Sarah. Character arc-nya memang luar biasa!',
          likesCount: 3,
        ),
        Comment(
          userName: 'Maya Sari',
          userImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
          timeAgo: '45 menit yang lalu',
          text: 'Saya juga terkesan dengan plot twist di chapter 12.',
          likesCount: 1,
        ),
      ],
    ),
    Comment(
      userName: 'Prof. David Wilson',
      userImageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
      timeAgo: '1 jam yang lalu',
      text:
          'Bagus sekali resensinya! Apakah ada rencana untuk review buku-buku lain dari author yang sama?',
      isExpert: true,
      likesCount: 8,
      repliesCount: 1,
      replies: [
        Comment(
          userName: 'Reviewer',
          userImageUrl: 'https://randomuser.me/api/portraits/women/3.jpg',
          timeAgo: '30 menit yang lalu',
          text:
              'Terima kasih Prof. David! Ya, saya sedang membaca karya terbaru beliau.',
          likesCount: 2,
        ),
      ],
    ),
    Comment(
      userName: 'Rina Putri',
      userImageUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
      timeAgo: '45 menit yang lalu',
      text:
          'Setelah baca resensi ini jadi pengen beli bukunya! Dimana ya bisa beli yang original?',
      likesCount: 5,
      repliesCount: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollProgress);
  }

  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _scrollProgress = maxScroll > 0 ? currentScroll / maxScroll : 0.0;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    _commentController.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
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
      backgroundColor: _isReadingMode ? Colors.white : Colors.grey[50],
      appBar: _isReadingMode ? null : _buildAppBar(),
      body: Column(
        children: [
          // Reading Progress Indicator
          if (!_isReadingMode)
            Container(
              height: 3,
              child: LinearProgressIndicator(
                value: _scrollProgress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          // Reading Mode Header
          if (_isReadingMode) _buildReadingModeHeader(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildFullReviewContent(currentReview),
                  if (!_isReadingMode) 16.height,
                  if (!_isReadingMode && _showOtherReviews)
                    _buildOtherReviewsList(currentReview, allReviews),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingButtons(),
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
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
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

  Widget _buildReadingModeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => setState(() => _isReadingMode = false),
            ),
            Expanded(
              child: Text(
                'Mode Membaca',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
            _buildFontControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildFontControls() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.text_decrease, size: 20),
          onPressed: _decreaseFontSize,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_fontSize.toInt()}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.text_increase, size: 20),
          onPressed: _increaseFontSize,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildFullReviewContent(ReadingReview currentReview) {
    return Container(
      width: double.infinity,
      margin: _isReadingMode ? EdgeInsets.zero : const EdgeInsets.all(16),
      decoration:
          _isReadingMode
              ? null
              : BoxDecoration(
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
          if (!_isReadingMode) _buildBookHeader(currentReview),
          _buildReviewContent(currentReview),
          if (!_isReadingMode) _buildReviewFooter(),
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
      padding: EdgeInsets.symmetric(
        horizontal: _isReadingMode ? 24 : 20,
        vertical: _isReadingMode ? 8 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isReadingMode) const Divider(height: 1),
          if (!_isReadingMode) 20.height,
          if (!_isReadingMode)
            const Text(
              'Resensi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          if (!_isReadingMode) 12.height,
          Text(
            currentReview.content,
            style: TextStyle(
              fontSize: _fontSize,
              color: _isReadingMode ? Colors.black : Colors.black87,
              height: _isReadingMode ? 1.8 : 1.6,
              letterSpacing: _isReadingMode ? 0.3 : 0.0,
            ),
            textAlign: TextAlign.justify,
          ),
          if (!_isReadingMode) 24.height,
          if (_isReadingMode) 32.height,
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
                () => context.showCustomSnackbar(
                  message: 'Anda menyukai bacaan ini',

                  type: SnackbarType.warning,
                ),
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

    if (otherReviews.isEmpty || !_showOtherReviews) {
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Resensi Lainnya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
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
                    '${otherReviews.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_isReadingMode) ...[
          FloatingActionButton(
            tooltip: 'Mode Membaca',
            heroTag: "reading_mode",
            mini: true,
            onPressed: _toggleReadingMode,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.chrome_reader_mode, color: Colors.white),
          ),
          const SizedBox(height: 8),
        ],
        if (_isReadingMode) ...[
          FloatingActionButton(
            tooltip: 'Keluar Mode Membaca',
            heroTag: "exit_reading",
            mini: true,
            onPressed: _toggleReadingMode,
            backgroundColor: Colors.grey[600],
            child: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          tooltip:
              _showOtherReviews
                  ? 'Sembunyikan Resensi Lainnya'
                  : 'Tampilkan Resensi Lainnya',
          heroTag: "toggle_reviews",
          mini: true,
          onPressed: _toggleOtherReviews,
          backgroundColor: Colors.white,
          child: Icon(
            _showOtherReviews ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _toggleReadingMode() {
    setState(() {
      _isReadingMode = !_isReadingMode;
    });
  }

  void _toggleOtherReviews() {
    setState(() {
      _showOtherReviews = !_showOtherReviews;
    });
  }

  void _increaseFontSize() {
    setState(() {
      if (_fontSize < 24.0) _fontSize += 1.0;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > 12.0) _fontSize -= 1.0;
    });
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
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
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
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Komentar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                        '${_comments.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Comments List
          Expanded(
            child:
                _comments.isEmpty
                    ? const Center(
                      child: Text(
                        'Belum ada komentar\nJadilah yang pertama berkomentar!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return _buildCommentItem(_comments[index], index);
                      },
                    ),
          ),
          // Comment Input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(comment.userImageUrl),
                        ),
                        if (comment.isExpert == true)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  comment.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                              if (comment.isExpert == true) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            comment.timeAgo,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                      onSelected: (value) {
                        _handleCommentAction(value, comment);
                      },
                      itemBuilder:
                          (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'reply',
                              child: Row(
                                children: [
                                  Icon(Icons.reply, size: 18),
                                  SizedBox(width: 8),
                                  Text('Balas'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'report',
                              child: Row(
                                children: [
                                  Icon(Icons.flag_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Laporkan'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'block',
                              child: Row(
                                children: [
                                  Icon(Icons.block, size: 18),
                                  SizedBox(width: 8),
                                  Text('Blokir'),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  comment.text,
                  style: const TextStyle(fontSize: 14.0, height: 1.4),
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    _buildInteractionButton(
                      icon: Icons.thumb_up_outlined,
                      count: comment.likesCount ?? 0,
                      onTap: () => _handleLike(comment),
                    ),
                    const SizedBox(width: 16),
                    _buildInteractionButton(
                      icon: Icons.chat_bubble_outline,
                      count: comment.repliesCount ?? 0,
                      onTap: () => _handleReply(comment),
                    ),
                    const Spacer(),
                    if (comment.replies != null &&
                        comment.replies!.isNotEmpty) ...[
                      _buildViewRepliesButton(comment, index),
                      const SizedBox(width: 8),
                    ],
                    TextButton.icon(
                      onPressed: () => _handleShare(comment),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Bagikan'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Display replies with animation
          if (comment.replies != null &&
              comment.replies!.isNotEmpty &&
              _expandedComments.contains(index))
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                children:
                    comment.replies!
                        .map((reply) => _buildReplyItem(reply))
                        .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(Comment reply) {
    return Container(
      margin: const EdgeInsets.only(left: 32, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thread line indicator
          Container(
            width: 2,
            height: 80,
            margin: const EdgeInsets.only(right: 12, top: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          // Reply content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(reply.userImageUrl),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  reply.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                  ),
                                ),
                                if (reply.isExpert == true) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 12,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              reply.timeAgo,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Colors.grey[600],
                          size: 16,
                        ),
                        onSelected: (value) {
                          _handleCommentAction(value, reply);
                        },
                        itemBuilder:
                            (BuildContext context) => [
                              const PopupMenuItem(
                                value: 'reply',
                                child: Row(
                                  children: [
                                    Icon(Icons.reply, size: 16),
                                    SizedBox(width: 8),
                                    Text('Balas'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'report',
                                child: Row(
                                  children: [
                                    Icon(Icons.flag_outlined, size: 16),
                                    SizedBox(width: 8),
                                    Text('Laporkan'),
                                  ],
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    reply.text,
                    style: const TextStyle(fontSize: 13.0, height: 1.3),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      _buildInteractionButton(
                        icon: Icons.thumb_up_outlined,
                        count: reply.likesCount ?? 0,
                        onTap: () => _handleLike(reply),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => _handleReply(reply),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.reply,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Balas',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildViewRepliesButton(Comment comment, int commentIndex) {
    final isExpanded = _expandedComments.contains(commentIndex);
    final repliesCount = comment.repliesCount ?? 0;

    return InkWell(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedComments.remove(commentIndex);
          } else {
            _expandedComments.add(commentIndex);
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isExpanded
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isExpanded
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 16,
              color: isExpanded ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              isExpanded ? 'Sembunyikan' : 'Lihat $repliesCount balasan',
              style: TextStyle(
                color: isExpanded ? AppColors.primary : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25.0),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Tulis komentar Anda...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _commentController,
              builder: (context, value, child) {
                final hasText = value.text.trim().isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    color: hasText ? AppColors.primary : Colors.grey[400],
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: hasText ? _sendComment : null,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          hasText ? Icons.send : Icons.send_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Comment interaction methods
  void _handleCommentAction(String action, Comment comment) {
    switch (action) {
      case 'reply':
        _handleReply(comment);
        break;
      case 'report':
        _showInteractionFeedback('Laporan dikirim 🚨');
        break;
      case 'block':
        _showInteractionFeedback('Pengguna diblokir 🚫');
        break;
    }
  }

  void _handleLike(Comment comment) {
    _showInteractionFeedback('Disukai! 👍');
  }

  void _handleReply(Comment comment) {
    _showReplyBottomSheet(comment);
  }

  void _handleShare(Comment comment) {
    _showInteractionFeedback('Link disalin ke clipboard 📋');
  }

  void _sendComment() {
    if (_commentController.text.trim().isNotEmpty) {
      _showInteractionFeedback('Komentar dikirim! 🎉');
      _commentController.clear();
    }
  }

  void _showReplyBottomSheet(Comment comment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildReplyBottomSheet(comment),
    ).then((_) {
      _replyController.clear();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _replyFocusNode.requestFocus();
    });
  }

  Widget _buildReplyBottomSheet(Comment comment) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Icon(Icons.reply, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Balas Komentar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Original comment preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(comment.userImageUrl),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  comment.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                if (comment.isExpert == true) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 14,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              comment.timeAgo,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comment.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Reply input field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _replyController,
                focusNode: _replyFocusNode,
                style: const TextStyle(fontSize: 14),
                maxLines: null,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Tulis balasan untuk ${comment.userName}...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _replyController.clear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _replyController,
                    builder: (context, value, child) {
                      final hasText = value.text.trim().isNotEmpty;
                      return ElevatedButton(
                        onPressed:
                            hasText
                                ? () => _sendReplyFromBottomSheet(comment)
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              hasText ? AppColors.primary : Colors.grey[400],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 16, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Kirim Balasan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _sendReplyFromBottomSheet(Comment comment) {
    if (_replyController.text.trim().isNotEmpty) {
      Navigator.pop(context);
      _showInteractionFeedback('Balasan dikirim! 🎉');
      _replyController.clear();
    }
  }

  void _showInteractionFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
