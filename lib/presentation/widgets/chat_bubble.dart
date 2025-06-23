import 'package:flutter/material.dart';

import '../models/chat_model.dart';
import '../themes/color_schemes.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final bool showTimestamp;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onReply;

  const ChatBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.showTimestamp = true,
    this.onTap,
    this.onLongPress,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe && showAvatar)
            _buildAvatar()
          else if (!message.isMe)
            const SizedBox(width: 40),

          const SizedBox(width: 8),

          Flexible(
            child: Column(
              crossAxisAlignment:
                  message.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                if (!message.isMe &&
                    showAvatar &&
                    message.senderName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 12),
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
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _getBubbleColor(),
                      borderRadius: _getBorderRadius(),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.replyToMessageId != null)
                          _buildReplyIndicator(),

                        _buildMessageContent(),

                        if (showTimestamp) ...[
                          const SizedBox(height: 6),
                          _buildTimestampAndStatus(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          if (message.isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundImage:
          message.senderAvatar != null
              ? NetworkImage(message.senderAvatar!)
              : null,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      child:
          message.senderAvatar == null
              ? Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              )
              : null,
    );
  }

  Widget _buildReplyIndicator() {
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
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: 14,
            color:
                message.isMe
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Replying to message...', // You can fetch the actual reply message
              style: TextStyle(
                color:
                    message.isMe
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage();
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.file:
        return _buildFileMessage();
      case MessageType.audio:
        return _buildAudioMessage();
      case MessageType.reply:
        return _buildTextMessage(); // Reply is just text with indicator
    }
  }

  Widget _buildTextMessage() {
    return Text(
      message.text,
      style: TextStyle(
        color: message.isMe ? Colors.white : Colors.black87,
        fontSize: 16,
        height: 1.3,
      ),
    );
  }

  Widget _buildImageMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
          ),
          child: const Center(
            child: Icon(Icons.image, size: 48, color: Colors.grey),
          ),
        ),
        if (message.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildTextMessage(),
        ],
      ],
    );
  }

  Widget _buildFileMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                message.isMe
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.insert_drive_file,
            color: message.isMe ? Colors.white : AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Document.pdf', // You can get filename from message
                style: TextStyle(
                  color: message.isMe ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '2.5 MB', // You can get file size from message
                style: TextStyle(
                  color:
                      message.isMe
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                message.isMe
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow,
            color: message.isMe ? Colors.white : AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color:
                      message.isMe
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: List.generate(
                    20,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color:
                              message.isMe ? Colors.white : AppColors.primary,
                          borderRadius: BorderRadius.circular(1),
                        ),
                        height: 8 + (index % 4) * 3.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '0:42', // You can get duration from message
                style: TextStyle(
                  color:
                      message.isMe
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampAndStatus() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            color:
                message.isMe ? Colors.white.withOpacity(0.7) : Colors.grey[500],
            fontSize: 11,
          ),
        ),
        if (message.isMe) ...[
          const SizedBox(width: 4),
          _buildMessageStatusIcon(),
        ],
      ],
    );
  }

  Widget _buildMessageStatusIcon() {
    switch (message.status) {
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

  Color _getBubbleColor() {
    return message.isMe ? AppColors.primary : Colors.white;
  }

  BorderRadius _getBorderRadius() {
    return BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(message.isMe ? 20 : 4),
      bottomRight: Radius.circular(message.isMe ? 4 : 20),
    );
  }
}

// Quick reply widget for common responses
class QuickReplyWidget extends StatelessWidget {
  final List<String> quickReplies;
  final Function(String) onReplySelected;

  const QuickReplyWidget({
    super.key,
    required this.quickReplies,
    required this.onReplySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickReplies.length,
        itemBuilder: (context, index) {
          final reply = quickReplies[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                reply,
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              onPressed: () => onReplySelected(reply),
            ),
          );
        },
      ),
    );
  }
}

// Typing indicator widget
class TypingIndicator extends StatefulWidget {
  final String? userName;

  const TypingIndicator({super.key, this.userName});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          const SizedBox(width: 48), // Space for avatar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.userName != null) ...[
                  Text(
                    '${widget.userName} sedang mengetik',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final delay = index * 0.3;
                        final value = (_controller.value - delay) % 1;
                        final opacity = value > 0.5 ? 1.0 : 0.3;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
