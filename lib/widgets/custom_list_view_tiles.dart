//Packages
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//Widgets
import '../widgets/app_widgets.dart';
import '../widgets/rounded_image.dart';
import '../widgets/message_bubbles.dart';

//Models
import '../models/chat_message.dart';
import '../models/chat_user.dart';

//Themes
import '../themes/app_theme.dart';

const double _avatarSize = 50;

const TextStyle _titleStyle = TextStyle(
  color: AppColors.text,
  fontSize: 16,
  fontWeight: FontWeight.w600,
  height: 1.4,
);

const TextStyle _subtitleStyle = TextStyle(
  color: AppColors.muted,
  fontSize: 13,
  fontWeight: FontWeight.w400,
  height: 1.5,
);

// Shared shape of the rows in the Chats and Users lists
Widget _listTile({
  required Widget leading,
  required Widget title,
  required Widget subtitle,
  required Function onTap,
  Widget? trailing,
  bool isHighlighted = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Material(
      color: isHighlighted ? AppColors.primarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [title, const SizedBox(height: 1), subtitle],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing,
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class CustomListViewTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isSelected;
  final Function onTap;

  const CustomListViewTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _listTile(
      onTap: onTap,
      isHighlighted: isSelected,
      leading: RoundedImageNetworkWithStatusIndicator(
        size: _avatarSize,
        imagePath: imagePath,
        isActive: isActive,
      ),
      title: ContentText(title, maxLines: 1, style: _titleStyle),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _subtitleStyle,
      ),
      trailing: _selectionMark(),
    );
  }

  Widget _selectionMark() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.offline,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}

class CustomListViewTileWithActivity extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final bool isGroup;
  // Shown before the subtitle, e.g. a photo icon for an image message
  final IconData? subtitleIcon;
  // Shown at the end of the row: when the last message was sent
  final String? time;
  final Function onTap;

  const CustomListViewTileWithActivity({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isActivity,
    required this.onTap,
    this.isGroup = false,
    this.subtitleIcon,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return _listTile(
      onTap: onTap,
      leading: RoundedImageNetworkWithStatusIndicator(
        size: _avatarSize,
        imagePath: imagePath,
        isActive: isActive,
        placeholderIcon: isGroup ? Icons.groups : Icons.person,
      ),
      title: Row(
        children: [
          Expanded(
            child: ContentText(title, maxLines: 1, style: _titleStyle),
          ),
          if (time != null) ...[
            const SizedBox(width: 8),
            Text(
              time!,
              style: const TextStyle(color: AppColors.hint, fontSize: 12),
            ),
          ],
        ],
      ),
      subtitle: isActivity
          ? Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SpinKitThreeBounce(
            color: AppColors.primaryLight,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            context.tr('typing'),
            style: _subtitleStyle.copyWith(color: AppColors.primaryLight),
          ),
        ],
      )
          : Row(
        children: [
          if (subtitleIcon != null) ...[
            Icon(subtitleIcon, size: 15, color: AppColors.muted),
            const SizedBox(width: 5),
          ],
          Expanded(
            child: ContentText(subtitle, maxLines: 1, style: _subtitleStyle),
          ),
        ],
      ),
    );
  }
}

class CustomChatListViewTile extends StatelessWidget {
  final double width;
  final bool isOwnMessage;
  final ChatMessage message;
  final ChatUser sender;
  // Group chats name the sender above each message of the other members
  final bool showSenderName;

  const CustomChatListViewTile({
    super.key,
    required this.width,
    required this.isOwnMessage,
    required this.message,
    required this.sender,
    this.showSenderName = false,
  });

  @override
  Widget build(BuildContext context) {
    final String? senderName =
        showSenderName && !isOwnMessage ? userName(context, sender) : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
        isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage) ...[
            RoundedImageNetwork(imagePath: sender.imageURL, size: 30),
            const SizedBox(width: 8),
          ],
          message.type == MessageType.IMAGE
              ? ImageMessageBubble(
            isOwnMessage: isOwnMessage,
            message: message,
            height: width * 0.50,
            width: width * 0.66,
            senderName: senderName,
          )
              : TextMessageBubble(
            isOwnMessage: isOwnMessage,
            message: message,
            width: width * 0.78,
            senderName: senderName,
          ),
        ],
      ),
    );
  }
}
