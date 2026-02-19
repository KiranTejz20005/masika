import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/specialist_model.dart';

const _maroon = Color(0xFF8D2D3B);
const _bg = Color(0xFFF8F7F5);
const _cardBg = Color(0xFFFFFFFF);
const _titleColor = Color(0xFF1A1A1A);
const _subtitleGray = Color(0xFF6B6B6B);
const _bubbleOut = Color(0xFFE8E8E8);
const _bubbleIn = Color(0xFF8D2D3B);

/// Chat screen with a specialist. Opened when user taps Chat on a specialist card.
class SpecialistChatScreen extends StatefulWidget {
  const SpecialistChatScreen({super.key, required this.specialist});

  final Specialist specialist;

  @override
  State<SpecialistChatScreen> createState() => _SpecialistChatScreenState();
}

class _SpecialistChatScreenState extends State<SpecialistChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      _ChatMessage(isFromUser: false, text: 'Hello! How can I help you today?', time: '10:00 AM'),
      _ChatMessage(isFromUser: true, text: 'I\'d like to discuss my recent lab results.', time: '10:02 AM'),
      _ChatMessage(isFromUser: false, text: 'Of course. Please share when you\'re ready, and we can go through them together.', time: '10:05 AM'),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    _messageController.clear();
    setState(() {
      _messages.add(_ChatMessage(isFromUser: true, text: text, time: _formatTime(DateTime.now())));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime d) {
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final am = d.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $am';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.specialist;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: _maroon, size: 18),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                s.imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 40,
                  height: 40,
                  color: const Color(0xFFF5F3F4),
                  child: const Icon(Icons.person_rounded, color: _maroon, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    s.specialty,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _subtitleGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: m.isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!m.isFromUser) _buildAvatar(s.imageUrl),
                      if (!m.isFromUser) const SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: m.isFromUser ? _bubbleIn : _bubbleOut,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(m.isFromUser ? 16 : 4),
                              bottomRight: Radius.circular(m.isFromUser ? 4 : 16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                m.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: m.isFromUser ? Colors.white : _titleColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m.time,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: m.isFromUser ? Colors.white70 : _subtitleGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (m.isFromUser) const SizedBox(width: 10),
                      if (m.isFromUser) _buildAvatar(s.imageUrl, isUser: true),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildAvatar(String imageUrl, {bool isUser = false}) {
    if (isUser) {
      return const SizedBox(
        width: 36,
        height: 36,
        child: CircleAvatar(
          backgroundColor: Color(0xFFE8E8E8),
          child: Icon(Icons.person_rounded, color: _subtitleGray, size: 20),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 36,
          height: 36,
          color: const Color(0xFFF5F3F4),
          child: const Icon(Icons.person_rounded, color: _maroon, size: 20),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      color: _cardBg,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3F4),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(fontSize: 14, color: _subtitleGray),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 14, color: _titleColor),
                  maxLines: 3,
                  minLines: 1,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: _maroon,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: _sendMessage,
                borderRadius: BorderRadius.circular(24),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final bool isFromUser;
  final String text;
  final String time;

  _ChatMessage({required this.isFromUser, required this.text, required this.time});
}
