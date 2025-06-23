import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../themes/color_schemes.dart';

// Model untuk chat conversation
class ChatConversation {
  final String id;
  final String title;
  final String? avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isGroup;
  final List<String>? participants;

  ChatConversation({
    required this.id,
    required this.title,
    this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isGroup = false,
    this.participants,
  });
}

// Provider untuk chat conversations
final chatConversationsProvider =
    StateNotifierProvider<ChatConversationsNotifier, List<ChatConversation>>((
      ref,
    ) {
      return ChatConversationsNotifier();
    });

class ChatConversationsNotifier extends StateNotifier<List<ChatConversation>> {
  ChatConversationsNotifier() : super(_dummyConversations);

  void markAsRead(String conversationId) {
    state =
        state.map((conversation) {
          if (conversation.id == conversationId) {
            return ChatConversation(
              id: conversation.id,
              title: conversation.title,
              avatar: conversation.avatar,
              lastMessage: conversation.lastMessage,
              lastMessageTime: conversation.lastMessageTime,
              unreadCount: 0,
              isOnline: conversation.isOnline,
              isGroup: conversation.isGroup,
              participants: conversation.participants,
            );
          }
          return conversation;
        }).toList();
  }

  static final List<ChatConversation> _dummyConversations = [
    ChatConversation(
      id: '1',
      title: 'Dr. Sarah Chen',
      avatar: 'https://randomuser.me/api/portraits/women/1.jpg',
      lastMessage:
          'Exactly! Dan ini juga berkaitan dengan cognitive biases. Banyak bias yang terjadi karena kita terlalu mengandalkan System 1.',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
      unreadCount: 2,
      isOnline: true,
    ),
    ChatConversation(
      id: '2',
      title: 'Grup Diskusi Psikologi',
      avatar: null,
      lastMessage:
          'Ahmad: Saya setuju dengan pendapat Prof. Maria tentang mindfulness therapy',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadCount: 5,
      isGroup: true,
      participants: ['Ahmad', 'Maria', 'Budi', '+7 lainnya'],
    ),
    ChatConversation(
      id: '3',
      title: 'Prof. David Wilson',
      avatar: 'https://randomuser.me/api/portraits/men/2.jpg',
      lastMessage: 'Terima kasih untuk sharing artikel yang kemarin!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      isOnline: false,
    ),
    ChatConversation(
      id: '4',
      title: 'Rina Sari',
      avatar: 'https://randomuser.me/api/portraits/women/4.jpg',
      lastMessage: 'Bukunya sudah sampai belum? Saya juga mau beli 😊',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 1,
      isOnline: true,
    ),
    ChatConversation(
      id: '5',
      title: 'Study Group Cognitive Science',
      avatar: null,
      lastMessage: 'Meeting hari Sabtu jam 2 siang ya teman-teman!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 4)),
      unreadCount: 0,
      isGroup: true,
      participants: ['Sarah', 'David', 'Rina', '+12 lainnya'],
    ),
    ChatConversation(
      id: '6',
      title: 'Maya Sari',
      avatar: 'https://randomuser.me/api/portraits/women/2.jpg',
      lastMessage: 'Saya juga terkesan dengan plot twist di chapter 12.',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: false,
    ),
  ];
}

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(chatConversationsProvider);
    final filteredConversations = _filterConversations(conversations);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child:
                filteredConversations.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = filteredConversations[index];
                        return _buildConversationItem(conversation);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatOptions();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Pesan',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Toggle search bar or focus search
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            _showChatListOptions();
          },
        ),
      ],
      backgroundColor: AppColors.primary,
      elevation: 0,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Cari pesan atau kontak...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildConversationItem(ChatConversation conversation) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            conversation.avatar != null
                ? CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(conversation.avatar!),
                )
                : CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      conversation.isGroup
                          ? Colors.blue[100]
                          : AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    conversation.isGroup ? Icons.group : Icons.person,
                    color:
                        conversation.isGroup ? Colors.blue : AppColors.primary,
                    size: 24,
                  ),
                ),
            if (conversation.isOnline && !conversation.isGroup)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.title,
                style: TextStyle(
                  fontWeight:
                      conversation.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTime(conversation.lastMessageTime),
              style: TextStyle(
                fontSize: 12,
                color:
                    conversation.unreadCount > 0
                        ? AppColors.primary
                        : Colors.grey[600],
                fontWeight:
                    conversation.unreadCount > 0
                        ? FontWeight.w600
                        : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    conversation.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          conversation.unreadCount > 0
                              ? Colors.black87
                              : Colors.grey[600],
                      fontWeight:
                          conversation.unreadCount > 0
                              ? FontWeight.w500
                              : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (conversation.unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      conversation.unreadCount > 9
                          ? '9+'
                          : conversation.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (conversation.isGroup && conversation.participants != null) ...[
              const SizedBox(height: 4),
              Text(
                conversation.participants!.join(', '),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        onTap: () {
          // Mark as read
          if (conversation.unreadCount > 0) {
            ref
                .read(chatConversationsProvider.notifier)
                .markAsRead(conversation.id);
          }

          // Navigate to chat page
          _navigateToChat(conversation);
        },
        onLongPress: () {
          _showConversationOptions(conversation);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Tidak ada pesan ditemukan'
                : 'Belum ada percakapan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Coba kata kunci yang berbeda'
                : 'Mulai percakapan dengan menekan tombol chat',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<ChatConversation> _filterConversations(
    List<ChatConversation> conversations,
  ) {
    if (_searchQuery.isEmpty) return conversations;

    return conversations.where((conversation) {
      return conversation.title.toLowerCase().contains(_searchQuery) ||
          conversation.lastMessage.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      // Today - show time
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      // This week - show day
      const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      return days[time.weekday - 1];
    } else {
      // Older - show date
      return '${time.day}/${time.month}';
    }
  }

  void _navigateToChat(ChatConversation conversation) {
    // Navigate to chat page using GoRouter
    final uri = Uri(
      path: '/home/chat/${conversation.id}',
      queryParameters: {
        'title': conversation.title,
        if (conversation.avatar != null) 'avatar': conversation.avatar!,
      },
    );
    context.go(uri.toString());
  }

  void _showConversationOptions(ChatConversation conversation) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.push_pin, color: AppColors.primary),
                  title: const Text('Pin Chat'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Pin Chat');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_off),
                  title: const Text('Mute Notifications'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Mute Notifications');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.archive),
                  title: const Text('Archive'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Archive Chat');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(conversation);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.person_add, color: AppColors.primary),
                  title: const Text('New Chat'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('New Chat');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.group_add, color: AppColors.primary),
                  title: const Text('New Group'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('New Group');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.primary,
                  ),
                  title: const Text('Scan QR Code'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('QR Code Scanner');
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showChatListOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Chat Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Chat Settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.archive),
                  title: const Text('Archived Chats'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Archived Chats');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Help');
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showDeleteConfirmation(ChatConversation conversation) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Chat'),
            content: Text(
              'Are you sure you want to delete this chat with ${conversation.title}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showFeatureNotAvailable('Delete Chat');
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showFeatureNotAvailable(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature belum tersedia'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
