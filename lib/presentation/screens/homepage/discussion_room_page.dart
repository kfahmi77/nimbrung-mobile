import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/presentation/routes/route_name.dart';
import 'package:nimbrung_mobile/presentation/themes/color_schemes.dart';

import '../../../features/discussions/comment.dart';
import '../../widgets/chat_bot_avatar.dart';

class DiscussionPage extends StatefulWidget {
  const DiscussionPage({super.key});

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isTyping = false;
  bool _showScrollToBottom = false;

  // Enhanced dummy list of comments with more variety
  final List<Comment> _comments = [
    Comment(
      userName: 'Dr. Johannes Falk',
      userImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      timeAgo: '2 jam yang lalu',
      text:
          'Topik kognisi ini sangat relevan dengan penelitian terbaru di bidang neurosains. Ada beberapa studi menarik yang menunjukkan bagaimana proses kognitif dapat dioptimalkan melalui latihan mindfulness.',
      isExpert: true,
      likesCount: 12,
      repliesCount: 3,
    ),
    Comment(
      userName: 'Birgitta Mattsson',
      userImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
      timeAgo: '1 jam yang lalu',
      text:
          'Setuju! Saya juga pernah membaca tentang dual-process theory. Menarik bagaimana otak kita memproses informasi secara otomatis dan terkontrol.',
      likesCount: 8,
      repliesCount: 1,
    ),
    Comment(
      userName: 'Jessica Åberg',
      userImageUrl: 'https://randomuser.me/api/portraits/women/3.jpg',
      timeAgo: '45 menit yang lalu',
      text:
          'Apakah ada rekomendasi buku lain tentang cognitive psychology yang lebih mudah dipahami untuk pemula? 📚',
      likesCount: 5,
      repliesCount: 2,
    ),
    Comment(
      userName: 'Prof. Lovisa Wallin',
      userImageUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
      timeAgo: '30 menit yang lalu',
      text:
          'Saya merekomendasikan "Thinking, Fast and Slow" oleh Daniel Kahneman untuk pemahaman yang lebih aplikatif tentang cognitive biases.',
      isExpert: true,
      likesCount: 15,
      repliesCount: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _scrollController.addListener(() {
      setState(() {
        _showScrollToBottom = _scrollController.offset > 200;
      });
    });

    _messageController.addListener(() {
      setState(() {
        _isTyping = _messageController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildEnhancedAppBar(),
      body: Column(
        children: [
          _buildEnhancedHeaderSection(),
          _buildParticipantsInfo(),
          Expanded(
            child: Stack(
              children: [
                _buildCommentsList(),
                if (_showScrollToBottom) _buildScrollToBottomButton(),
              ],
            ),
          ),
          _buildEnhancedBottomInputField(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: ChatBotAvatar(),
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => context.pop(RouteNames.home),
      ),
      centerTitle: true,
      title: Column(
        children: [
          Text(
            'Ruang Nimbrung',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          Text(
            '${_comments.length + 99} peserta aktif',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.white),
          onPressed: () {
            _showBookmarkSnackbar();
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            _showShareBottomSheet();
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            _showMoreOptionsBottomSheet();
          },
        ),
      ],
      backgroundColor: AppColors.primary,
      elevation: 0,
      toolbarHeight: 70,
    );
  }

  Widget _buildEnhancedHeaderSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '💡 Disuksi hari ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              const Text(
                'Kognisi adalah proses mental yang mencakup persepsi, perhatian, ingatan, pemecahan masalah, dan pengambilan keputusan.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12.0),
              InkWell(
                onTap: () {
                  _showSourceBottomSheet();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.book_outlined,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Solso, R. L. (2008). Cognitive Psychology: Edisi Kedelapan. Erlangga.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.0,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.7),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantsInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 30,
            child: Stack(
              children: [
                _buildUserAvatar(
                  'https://randomuser.me/api/portraits/women/5.jpg',
                  position: 0,
                ),
                _buildUserAvatar(
                  'https://randomuser.me/api/portraits/men/6.jpg',
                  position: 1,
                ),
                _buildUserAvatar(
                  'https://randomuser.me/api/portraits/women/7.jpg',
                  position: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+ 99 Pengguna Lainnya',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'sedang berdiskusi',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutBack,
          child: _buildEnhancedCommentItem(_comments[index], index),
        );
      },
    );
  }

  Widget _buildUserAvatar(String imageUrl, {required int position}) {
    return Positioned(
      left: position * 20.0,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 15,
          backgroundImage: NetworkImage(imageUrl),
        ),
      ),
    );
  }

  Widget _buildEnhancedCommentItem(Comment comment, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
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

  Widget _buildScrollToBottomButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        onPressed: () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      ),
    );
  }

  Widget _buildEnhancedBottomInputField() {
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
                  controller: _messageController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Tulis pendapat Anda...',
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: _isTyping ? AppColors.primary : Colors.grey[400],
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _isTyping ? _sendMessage : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      _isTyping ? Icons.send : Icons.send_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced interaction methods
  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      // Add animation and feedback
      _showSendingFeedback();
      // TODO: Implement actual send logic
      _messageController.clear();
    }
  }

  void _showSendingFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Pesan terkirim! 🎉'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleLike(Comment comment) {
    // TODO: Implement like functionality
    _showInteractionFeedback('Disukai! 👍');
  }

  void _handleReply(Comment comment) {
    // TODO: Implement reply functionality
    _messageController.text = '@${comment.userName} ';
  }

  void _handleShare(Comment comment) {
    // TODO: Implement share functionality
    _showInteractionFeedback('Link disalin ke clipboard 📋');
  }

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

  void _showBookmarkSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Diskusi disimpan ke bookmark 🔖'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bagikan Diskusi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Salin Link'),
                  onTap: () {
                    Navigator.pop(context);
                    _showInteractionFeedback('Link disalin ke clipboard 📋');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Bagikan ke Aplikasi Lain'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement native sharing
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showMoreOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Opsi Lainnya',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifikasi Diskusi'),
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Laporkan Diskusi'),
                  onTap: () {
                    Navigator.pop(context);
                    _showInteractionFeedback('Laporan dikirim 🚨');
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sumber Referensi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Solso, R. L. (2008). Cognitive Psychology: Edisi Kedelapan. Erlangga.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buku ini membahas secara komprehensif tentang proses kognitif manusia, termasuk persepsi, memori, dan pemecahan masalah.',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
