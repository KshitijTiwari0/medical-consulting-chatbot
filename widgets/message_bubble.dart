import 'package:flutter/material.dart';
import 'package:flutter_proj/models/message_model.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

class MessageBubble extends StatefulWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (widget.message.audioUrl == null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(UrlSource(widget.message.audioUrl!));
      setState(() => _isPlaying = true);
      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() => _isPlaying = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 8).copyWith(
        left: widget.message.isUser ? 80 : 10,
        right: widget.message.isUser ? 10 : 80,
      ),
      decoration: BoxDecoration(
        color:
            widget.message.isUser
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft:
              widget.message.isUser ? const Radius.circular(12) : Radius.zero,
          bottomRight:
              widget.message.isUser ? Radius.zero : const Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message.audioUrl != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _playAudio,
                  color:
                      widget.message.isUser
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                ),
                Text(
                  'Audio message',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color:
                        widget.message.isUser
                            ? Colors.white70
                            : Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          Text(
            widget.message.message,
            style: TextStyle(
              fontSize: 16,
              color:
                  widget.message.isUser
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm').format(widget.message.date),
                style: TextStyle(
                  fontSize: 10,
                  color:
                      widget.message.isUser
                          ? Colors.white70
                          : Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer.withOpacity(0.7),
                ),
              ),
              if (widget.message.isUser)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 12,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
