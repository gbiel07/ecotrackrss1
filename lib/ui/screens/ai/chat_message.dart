import 'package:flutter/material.dart';

/// Mensagem do chat da Central de IA.
class ChatMessage {
  const ChatMessage.user(this.text)
      : fromUser = true,
        isPending = false;

  const ChatMessage.assistant(this.text)
      : fromUser = false,
        isPending = false;

  /// Mensagem temporária enquanto o assistente consulta os registros.
  const ChatMessage.pending()
      : text = 'Consultando registros locais...',
        fromUser = false,
        isPending = true;

  final String text;
  final bool fromUser;
  final bool isPending;
}

/// Balão de mensagem (.ai-message / .ai-user / .ai-assistant).
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.maxWidth});

  final ChatMessage message;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.fromUser;
    final background = fromUser ? const Color(0xFFE8EFFF) : const Color(0xFFEDF5F1);
    final foreground = fromUser ? const Color(0xFF25436D) : const Color(0xFF254B3E);

    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth > 0 ? maxWidth : double.infinity),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fromUser ? 'Você' : 'EcoTrack IA',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: foreground),
              ),
              const SizedBox(height: 5),
              if (message.isPending)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message.text,
                        style: TextStyle(fontSize: 12, height: 1.65, color: foreground),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  message.text,
                  style: TextStyle(fontSize: 12, height: 1.65, color: foreground),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
