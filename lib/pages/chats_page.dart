//Packages
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/chats_page_provider.dart';

//Services
import '../services/navigation_services.dart';

//Pages
import '../pages/chat_page.dart';

//Widgets
import '../widgets/app_widgets.dart';
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

//Models
import '../models/chat.dart';
import '../models/chat_user.dart';
import '../models/chat_message.dart';

class ChatsPage extends StatefulWidget {
  // Called by the button of the empty state, to open the Users tab
  final VoidCallback? onFindUsers;

  const ChatsPage({super.key, this.onFindUsers});

  @override
  State<StatefulWidget> createState() {
    return _ChatsPageState();
  }
}

class _ChatsPageState extends State<ChatsPage> {
  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late ChatsPageProvider _pageProvider;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatsPageProvider>(
          create: (_) => ChatsPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _pageProvider = context.watch<ChatsPageProvider>();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10, top: 8),
                  child: TopBar(
                    context.tr('chats'),
                    primaryAction: const AccountActions(),
                  ),
                ),
                const SizedBox(height: 4),
                _chatsList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chatsList() {
    List<Chat>? chats = _pageProvider.chats;
    return Expanded(
      child: (() {
        if (chats != null) {
          if (chats.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: chats.length,
              itemBuilder: (BuildContext context, int index) {
                return _chatTile(
                  chats[index],
                );
              },
            );
          } else {
            return StateMessage(
              icon: Icons.forum_outlined,
              title: context.tr('chats_empty_title'),
              body: context.tr('chats_empty_body'),
              actionLabel: context.tr('find_users'),
              onAction: widget.onFindUsers,
            );
          }
        } else if (_pageProvider.hasError) {
          return StateMessage(
            icon: Icons.cloud_off_outlined,
            title: context.tr('chats_error'),
            actionLabel: context.tr('retry'),
            onAction: () => _pageProvider.getChats(),
          );
        } else {
          return const LoadingView();
        }
      })(),
    );
  }

  Widget _chatTile(Chat chat) {
    List<ChatUser> recepients = chat.recepients();
    bool isActive = recepients.any((user) => user.wasRecentlyActive());
    String subtitleText = "";
    IconData? subtitleIcon;
    String? time;
    if (chat.messages.isNotEmpty) {
      ChatMessage lastMessage = chat.messages.first;
      time = timeAgo(context, lastMessage.sentTime);
      switch (lastMessage.type) {
        case MessageType.TEXT:
          subtitleText = lastMessage.content;
          break;
        case MessageType.IMAGE:
          subtitleText = context.tr('media_attachment');
          subtitleIcon = Icons.photo_outlined;
          break;
        default:
          subtitleText = context.tr('unsupported_message');
      }
    }
    return CustomListViewTileWithActivity(
      title: chatTitle(context, chat),
      subtitle: subtitleText,
      subtitleIcon: subtitleIcon,
      time: time,
      imagePath: chat.imageURL(),
      isActive: isActive,
      isActivity: chat.activity,
      isGroup: chat.group,
      onTap: () {
        _navigation.navigateToPage(
          ChatPage(chat: chat),
        );
      },
    );
  }
}
