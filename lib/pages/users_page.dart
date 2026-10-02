//Packages
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/users_page_provider.dart';

//Widgets
import '../widgets/app_widgets.dart';
import '../widgets/custom_input_fields.dart';
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/rounded_button.dart';

//Models
import '../models/chat_user.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UsersPageState();
  }
}

class _UsersPageState extends State<UsersPage> {
  late AuthenticationProvider _auth;
  late UsersPageProvider _pageProvider;

  final TextEditingController _searchFieldTextEditingController =
  TextEditingController();

  @override
  void dispose() {
    _searchFieldTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsersPageProvider>(
          create: (_) => UsersPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _pageProvider = context.watch<UsersPageProvider>();
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
                    context.tr('users'),
                    primaryAction: const AccountActions(),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CustomTextField(
                    onEditingComplete: (value) {
                      _pageProvider.getUsers(name: value);
                      FocusScope.of(context).unfocus();
                    },
                    hintText: context.tr('search_hint'),
                    obscureText: false,
                    controller: _searchFieldTextEditingController,
                    icon: Icons.search,
                  ),
                ),
                const SizedBox(height: 8),
                _usersList(),
                _createChatButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _usersList() {
    List<ChatUser>? users = _pageProvider.users;
    return Expanded(child: () {
      if (users != null) {
        if (users.isNotEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              return CustomListViewTile(
                title: userName(context, users[index]),
                subtitle: context.tr(
                  'last_active',
                  args: [timeAgo(context, users[index].lastActive)],
                ),
                imagePath: users[index].imageURL,
                isActive: users[index].wasRecentlyActive(),
                isSelected: _pageProvider.selectedUsers.contains(
                  users[index],
                ),
                onTap: () {
                  _pageProvider.updateSelectedUsers(
                    users[index],
                  );
                },
              );
            },
          );
        } else {
          bool isSearching =
              _searchFieldTextEditingController.text.trim().isNotEmpty;
          return StateMessage(
            icon: isSearching ? Icons.search_off : Icons.people_outline,
            title: context.tr('users_empty_title'),
            body: context.tr(
              isSearching ? 'users_empty_search_body' : 'users_empty_body',
            ),
          );
        }
      } else if (_pageProvider.hasError) {
        return StateMessage(
          icon: Icons.cloud_off_outlined,
          title: context.tr('users_error'),
          actionLabel: context.tr('retry'),
          onAction: () => _pageProvider.getUsers(
            name: _searchFieldTextEditingController.text,
          ),
        );
      } else {
        return const LoadingView();
      }
    }());
  }

  Widget _createChatButton() {
    int selectedCount = _pageProvider.selectedUsers.length;
    return Visibility(
      visible: selectedCount > 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
        child: RoundedButton(
          name: selectedCount == 1
              ? context.tr(
                  'chat_with',
                  args: [userName(context, _pageProvider.selectedUsers.first)],
                )
              : context.tr('create_group_chat', args: ['$selectedCount']),
          height: 54,
          width: double.infinity,
          isLoading: _pageProvider.isCreatingChat,
          onPressed: () async {
            bool isCreated = await _pageProvider.createChat();
            if (!isCreated && mounted) {
              showAppMessage(context, context.tr('create_chat_failed'));
            }
          },
        ),
      ),
    );
  }
}
