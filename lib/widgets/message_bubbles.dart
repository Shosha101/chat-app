import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

//Widgets
import '../widgets/app_widgets.dart';

//Models
import '../models/chat_message.dart';

//Themes
import '../themes/app_theme.dart';

// Own messages are blue with the tail at the end side; the others are grey
// with the tail at the start side. Both follow the reading direction.
BoxDecoration _bubbleDecoration(bool isOwnMessage) {
  return BoxDecoration(
    color: isOwnMessage ? null : AppColors.surfaceHigh,
    gradient: isOwnMessage
        ? const LinearGradient(
            colors: [AppColors.primaryBright, AppColors.primary],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          )
        : null,
    borderRadius: BorderRadiusDirectional.only(
      topStart: const Radius.circular(18),
      topEnd: const Radius.circular(18),
      bottomStart: Radius.circular(isOwnMessage ? 18 : 4),
      bottomEnd: Radius.circular(isOwnMessage ? 4 : 18),
    ),
  );
}

Widget _senderName(String name) {
  return ContentText(
    name,
    maxLines: 1,
    style: const TextStyle(
      color: AppColors.primaryLight,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      height: 1.5,
    ),
  );
}

Widget _sentTime(BuildContext context, ChatMessage message) {
  return Text(
    timeAgo(context, message.sentTime),
    textAlign: TextAlign.end,
    style: const TextStyle(
      color: AppColors.onBubble,
      fontSize: 11,
      height: 1.4,
    ),
  );
}

class TextMessageBubble extends StatelessWidget {
  final bool isOwnMessage;
  final ChatMessage message;
  // The widest the bubble may get; a short message takes less
  final double width;
  // Shown above the text: who wrote it, in a group chat
  final String? senderName;

  const TextMessageBubble(
      {super.key,
        required this.isOwnMessage,
        required this.message,
        required this.width,
        this.senderName});

  @override
  Widget build(BuildContext context) {
    // Only text and images can be sent; anything else has no content to show
    final String text = message.type == MessageType.TEXT
        ? message.content
        : context.tr('unsupported_message');
    return Container(
      constraints: BoxConstraints(maxWidth: width),
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 8),
      decoration: _bubbleDecoration(isOwnMessage),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (senderName != null) _senderName(senderName!),
            ContentText(
              text,
              alignWithContent: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 2),
            _sentTime(context, message),
          ],
        ),
      ),
    );
  }
}

class ImageMessageBubble extends StatelessWidget {
  final bool isOwnMessage;
  final ChatMessage message;
  final double height;
  final double width;
  final String? senderName;

  const ImageMessageBubble(
      {super.key,
        required this.isOwnMessage,
        required this.message,
        required this.height,
        required this.width,
        this.senderName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width + 8,
      padding: const EdgeInsets.all(4),
      decoration: _bubbleDecoration(isOwnMessage),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (senderName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
              child: _senderName(senderName!),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: height,
              width: width,
              child: Image.network(
                message.content,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  return frame == null
                      ? _placeholder(const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white70,
                          ),
                        ))
                      : child;
                },
                errorBuilder: (context, error, stackTrace) {
                  return _placeholder(const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white70,
                    size: 36,
                  ));
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 3),
            child: _sentTime(context, message),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(Widget child) {
    return ColoredBox(
      color: Colors.black26,
      child: Center(child: child),
    );
  }
}
