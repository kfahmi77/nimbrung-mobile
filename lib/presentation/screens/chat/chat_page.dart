import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/chat_model.dart';
import '../../themes/color_schemes.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String chatId;
  final String chatTitle;
  final String? chatAvatar;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.chatTitle,
    this.chatAvatar,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  late AnimationController _sendButtonAnimationController;
  late Animation<double> _sendButtonAnimation;
  bool _isTyping = false;
  ChatMessage? _replyToMessage;

  @override
  void initState() {
    super.initState();
    _sendButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _sendButtonAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _isTyping) {
        setState(() {
          _isTyping = hasText;
        });
        if (hasText) {
          _sendButtonAnimationController.forward();
        } else {
          _sendButtonAnimationController.reverse();
        }
      }
    });

    // Auto scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _sendButtonAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // Start from bottom
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final previousMessage =
                    index < messages.length - 1 ? messages[index + 1] : null;
                final showAvatar = _shouldShowAvatar(message, previousMessage);
                final showTimestamp = _shouldShowTimestamp(
                  message,
                  previousMessage,
                );

                return Column(
                  children: [
                    if (showTimestamp)
                      _buildTimestampDivider(message.timestamp),
                    _buildMessageBubble(message, showAvatar),
                  ],
                );
              },
            ),
          ),
          if (_replyToMessage != null) _buildReplyPreview(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          if (widget.chatAvatar != null)
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.chatAvatar!),
            )
          else
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                widget.chatTitle.isNotEmpty
                    ? widget.chatTitle[0].toUpperCase()
                    : 'C',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online', // You can make this dynamic
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: Colors.white),
          onPressed: () {
            // Video call functionality
            _showFeatureNotAvailable('Video Call');
          },
        ),
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {
            // Voice call functionality
            _showFeatureNotAvailable('Voice Call');
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            _showChatOptions();
          },
        ),
      ],
      backgroundColor: AppColors.primary,
      elevation: 0,
    );
  }

  Widget _buildTimestampDivider(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    String timeText;

    if (difference.inDays == 0) {
      timeText = 'Hari ini';
    } else if (difference.inDays == 1) {
      timeText = 'Kemarin';
    } else {
      timeText = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              timeText,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool showAvatar) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe && showAvatar)
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  message.senderAvatar != null
                      ? NetworkImage(message.senderAvatar!)
                      : null,
              child:
                  message.senderAvatar == null
                      ? Text(
                        message.senderName.isNotEmpty
                            ? message.senderName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            )
          else if (!message.isMe)
            const SizedBox(width: 32),

          const SizedBox(width: 8),

          Flexible(
            child: Column(
              crossAxisAlignment:
                  message.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                if (!message.isMe && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                GestureDetector(
                  onLongPress: () => _showMessageOptions(message),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: message.isMe ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(message.isMe ? 20 : 4),
                        bottomRight: Radius.circular(message.isMe ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.replyToMessageId != null)
                          _buildReplyIndicator(message),

                        Text(
                          message.text,
                          style: TextStyle(
                            color: message.isMe ? Colors.white : Colors.black87,
                            fontSize: 16,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color:
                                    message.isMe
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                            if (message.isMe) ...[
                              const SizedBox(width: 4),
                              _buildMessageStatusIcon(message.status),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          if (message.isMe)
            const SizedBox(width: 32)
          else if (showAvatar)
            const SizedBox(width: 0),
        ],
      ),
    );
  }

  Widget _buildReplyIndicator(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: message.isMe ? Colors.white.withOpacity(0.2) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: message.isMe ? Colors.white : AppColors.primary,
            width: 3,
          ),
        ),
      ),
      child: Text(
        'Replying to message...', // You can fetch the actual reply message
        style: TextStyle(
          color:
              message.isMe ? Colors.white.withOpacity(0.8) : Colors.grey[600],
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.7),
            ),
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 14,
          color: Colors.white.withOpacity(0.7),
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 14,
          color: Colors.white.withOpacity(0.7),
        );
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 14, color: Colors.blue[300]);
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 14, color: Colors.red[300]);
    }
  }

  Widget _buildReplyPreview() {
    if (_replyToMessage == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyToMessage!.senderName}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyToMessage!.text,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                _replyToMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add, color: AppColors.primary),
              onPressed: () {
                _showAttachmentOptions();
              },
            ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Ketik pesan...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            ScaleTransition(
              scale: _sendButtonAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: _isTyping ? AppColors.primary : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isTyping ? Icons.send : Icons.mic,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _isTyping ? _sendMessage : _startVoiceMessage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowAvatar(ChatMessage message, ChatMessage? previousMessage) {
    if (message.isMe) return false;
    if (previousMessage == null) return true;
    if (previousMessage.isMe) return true;
    if (previousMessage.senderId != message.senderId) return true;

    final timeDiff = message.timestamp.difference(previousMessage.timestamp);
    return timeDiff.inMinutes > 5;
  }

  bool _shouldShowTimestamp(ChatMessage message, ChatMessage? previousMessage) {
    if (previousMessage == null) return true;

    final timeDiff = message.timestamp.difference(previousMessage.timestamp);
    return timeDiff.inHours >= 1;
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderId: 'me',
      senderName: 'Anda',
      timestamp: DateTime.now(),
      isMe: true,
      status: MessageStatus.sending,
      replyToMessageId: _replyToMessage?.id,
    );

    ref.read(chatMessagesProvider.notifier).addMessage(message);
    _messageController.clear();

    setState(() {
      _replyToMessage = null;
    });

    _scrollToBottom();

    // Simulate message delivery
    Future.delayed(const Duration(seconds: 1), () {
      ref
          .read(chatMessagesProvider.notifier)
          .updateMessageStatus(message.id, MessageStatus.sent);
    });

    Future.delayed(const Duration(seconds: 2), () {
      ref
          .read(chatMessagesProvider.notifier)
          .updateMessageStatus(message.id, MessageStatus.delivered);
    });
  }

  void _startVoiceMessage() {
    _showFeatureNotAvailable('Voice Message');
  }

  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.reply),
                  title: const Text('Reply'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _replyToMessage = message;
                    });
                    _messageFocusNode.requestFocus();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy'),
                  onTap: () {
                    Navigator.pop(context);
                    // Copy to clipboard functionality
                    _showFeatureNotAvailable('Copy Message');
                  },
                ),
                if (message.isMe) ...[
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      _showFeatureNotAvailable('Edit Message');
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
                      _showFeatureNotAvailable('Delete Message');
                    },
                  ),
                ],
              ],
            ),
          ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo, color: AppColors.primary),
                  title: const Text('Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Photo Attachment');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.videocam, color: AppColors.primary),
                  title: const Text('Video'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Video Attachment');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.insert_drive_file,
                    color: AppColors.primary,
                  ),
                  title: const Text('Document'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Document Attachment');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.location_on, color: AppColors.primary),
                  title: const Text('Location'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Location Sharing');
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text('Search in Chat'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Search in Chat');
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
                  leading: const Icon(Icons.block),
                  title: const Text('Block User'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Block User');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report, color: Colors.red),
                  title: const Text(
                    'Report',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotAvailable('Report User');
                  },
                ),
              ],
            ),
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
