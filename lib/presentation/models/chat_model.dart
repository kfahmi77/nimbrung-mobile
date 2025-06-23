import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model untuk chat message
class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final DateTime timestamp;
  final bool isMe;
  final MessageType type;
  final MessageStatus status;
  final String? replyToMessageId;
  final List<String>? attachments;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.timestamp,
    required this.isMe,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.replyToMessageId,
    this.attachments,
  });
}

enum MessageType { text, image, file, audio, reply }

enum MessageStatus { sending, sent, delivered, read, failed }

// Provider untuk chat messages
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
      return ChatMessagesNotifier();
    });

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super(_dummyMessages);

  void addMessage(ChatMessage message) {
    state = [message, ...state];
  }

  void updateMessageStatus(String messageId, MessageStatus status) {
    state =
        state.map((message) {
          if (message.id == messageId) {
            return ChatMessage(
              id: message.id,
              text: message.text,
              senderId: message.senderId,
              senderName: message.senderName,
              senderAvatar: message.senderAvatar,
              timestamp: message.timestamp,
              isMe: message.isMe,
              type: message.type,
              status: status,
              replyToMessageId: message.replyToMessageId,
              attachments: message.attachments,
            );
          }
          return message;
        }).toList();
  }

  static final List<ChatMessage> _dummyMessages = [
    ChatMessage(
      id: '1',
      text:
          'Hai! Saya baru saja selesai membaca buku tentang cognitive psychology. Ada yang ingin didiskusikan?',
      senderId: 'user1',
      senderName: 'Dr. Sarah Chen',
      senderAvatar: 'https://randomuser.me/api/portraits/women/1.jpg',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isMe: false,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '2',
      text:
          'Wah menarik! Saya juga sedang belajar tentang itu. Bagian mana yang paling berkesan?',
      senderId: 'me',
      senderName: 'Anda',
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      isMe: true,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '3',
      text:
          'Bagian tentang dual-process theory sangat fascinating! Cara otak memproses informasi secara System 1 dan System 2 itu benar-benar eye-opening.',
      senderId: 'user1',
      senderName: 'Dr. Sarah Chen',
      senderAvatar: 'https://randomuser.me/api/portraits/women/1.jpg',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      isMe: false,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '4',
      text:
          'Betul sekali! System 1 yang cepat dan otomatis vs System 2 yang lambat tapi deliberate. Ini mempengaruhi decision making kita sehari-hari ya',
      senderId: 'me',
      senderName: 'Anda',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      isMe: true,
      status: MessageStatus.delivered,
    ),
    ChatMessage(
      id: '5',
      text:
          'Exactly! Dan ini juga berkaitan dengan cognitive biases. Banyak bias yang terjadi karena kita terlalu mengandalkan System 1.',
      senderId: 'user1',
      senderName: 'Dr. Sarah Chen',
      senderAvatar: 'https://randomuser.me/api/portraits/women/1.jpg',
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      isMe: false,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: '6',
      text:
          'Iya, seperti confirmation bias dan availability heuristic. Susah ya mengatur kapan harus menggunakan System 2 🤔',
      senderId: 'me',
      senderName: 'Anda',
      timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
      isMe: true,
      status: MessageStatus.sending,
    ),
  ];
}
