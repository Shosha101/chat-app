//Packages
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Widgets
import '../providers/chat_page_provider.dart';
import '../widgets/app_widgets.dart';
import '../widgets/rounded_image.dart';
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

//Models
import '../models/chat.dart';
import '../models/chat_message.dart';

//Providers
import '../providers/authentication_provider.dart';

//Themes
import '../themes/app_theme.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage({super.key, required this.chat});

  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;

  late TextEditingController _messageFieldTextEditingController;
  late ScrollController _messagesListViewController;

  @override
  void initState() {
    super.initState();
    _messageFieldTextEditingController = TextEditingController();
    _messagesListViewController = ScrollController();
  }

  @override
  void dispose() {
    _messageFieldTextEditingController.dispose();
    _messagesListViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatPageProvider>(
          create: (_) => ChatPageProvider(
              widget.chat.uid, _auth, _messagesListViewController),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _pageProvider = context.watch<ChatPageProvider>();
        return Scaffold(
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _topBar(),
                ),
                const Divider(),
                Expanded(child: _messagesListView()),
                _sendMessageForm(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topBar() {
    Chat chat = widget.chat;
    return TopBar(
      chatTitle(context, chat),
      fontSize: 17,
      // A group shows its size; a single chat shows when the other user was last active
      subtitle: chat.group
          ? context.plural('members_count', chat.members.length)
          : chat.recepients().isEmpty
              ? null
              : context.tr(
                  'last_active',
                  args: [timeAgo(context, chat.recepients().first.lastActive)],
                ),
      avatar: RoundedImageNetwork(
        imagePath: chat.imageURL(),
        size: 40,
        placeholderIcon: chat.group ? Icons.groups : Icons.person,
      ),
      primaryAction: IconButton(
        tooltip: context.tr('delete_chat'),
        icon: const Icon(
          Icons.delete_outline,
          color: AppColors.primaryLight,
        ),
        onPressed: () {
          _confirmDeleteChat();
        },
      ),
      secondryAction: IconButton(
        tooltip: context.tr('back'),
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.primaryLight,
        ),
        onPressed: () {
          _pageProvider.goBack();
        },
      ),
    );
  }

  // Deleting cannot be undone and removes the chat for every member, so it asks first
  void _confirmDeleteChat() {
    showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.tr('delete_chat')),
          content: Text(context.tr('delete_chat_body')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.tr('delete')),
            ),
          ],
        );
      },
    ).then((isConfirmed) {
      if (isConfirmed == true && mounted) {
        _pageProvider.deleteChat();
      }
    });
  }

  Widget _messagesListView() {
    List<ChatMessage>? messages = _pageProvider.messages;
    if (messages != null) {
      if (messages.isNotEmpty) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return ListView.builder(
              controller: _messagesListViewController,
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                ChatMessage message = messages[index];
                bool isOwnMessage = message.senderID == _auth.user.uid;
                return CustomChatListViewTile(
                  width: constraints.maxWidth - 24,
                  message: message,
                  isOwnMessage: isOwnMessage,
                  showSenderName: widget.chat.group,
                  sender: widget
                      .chat
                      .members
                      .firstWhere(
                        (member) => member.uid == message.senderID,
                    orElse: () => _auth.user, // Fallback to current user if no match
                  ),
                );
              },
            );
          },
        );
      } else {
        return StateMessage(
          icon: Icons.waving_hand_outlined,
          title: context.tr('messages_empty_title'),
          body: context.tr('messages_empty_body'),
        );
      }
    } else if (_pageProvider.hasError) {
      return StateMessage(
        icon: Icons.cloud_off_outlined,
        title: context.tr('messages_error'),
        actionLabel: context.tr('retry'),
        onAction: () => _pageProvider.listenToMessages(),
      );
    } else {
      return const LoadingView();
    }
  }

  Widget _sendMessageForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _imageMessageButton(),
          const SizedBox(width: 8),
          Expanded(child: _messageTextField()),
          const SizedBox(width: 8),
          _sendMessageButton(),
        ],
      ),
    );
  }

  Widget _messageTextField() {
    return TextField(
      controller: _messageFieldTextEditingController,
      style: const TextStyle(color: AppColors.text, fontSize: 15),
      minLines: 1,
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: context.tr('message_hint'),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        border: _messageFieldBorder(AppColors.border),
        enabledBorder: _messageFieldBorder(AppColors.border),
        focusedBorder: _messageFieldBorder(AppColors.primaryLight),
      ),
    );
  }

  OutlineInputBorder _messageFieldBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _sendMessageButton() {
    return SizedBox(
      height: 48,
      width: 48,
      child: IconButton(
        tooltip: context.tr('send'),
        style: IconButton.styleFrom(backgroundColor: AppColors.primary),
        icon: const Icon(
          Icons.send,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () {
          // A message of spaces only is not sent
          String text = _messageFieldTextEditingController.text.trim();
          if (text.isNotEmpty) {
            _pageProvider.message = text;
            _pageProvider.sendTextMessage();
            _messageFieldTextEditingController.clear();
          }
        },
      ),
    );
  }

  Widget _imageMessageButton() {
    return SizedBox(
      height: 48,
      width: 48,
      child: IconButton(
        tooltip: context.tr('send_image'),
        style: IconButton.styleFrom(backgroundColor: AppColors.surface),
        icon: _pageProvider.isSendingImage
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : const Icon(
                Icons.image_outlined,
                color: AppColors.primaryLight,
                size: 22,
              ),
        onPressed: _pageProvider.isSendingImage
            ? null
            : () async {
                bool isSent = await _pageProvider.sendImageMessage();
                if (!isSent && mounted) {
                  showAppMessage(context, context.tr('image_send_failed'));
                }
              },
      ),
    );
  }
}
