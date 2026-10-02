//Packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/database_services.dart';
import '../services/navigation_services.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/chat_user.dart';
import '../models/chat.dart';

//Pages
import '../pages/chat_page.dart';

class UsersPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;

  late DatabaseService _database;
  late NavigationService _navigation;

  List<ChatUser>? users;
  bool hasError = false;
  // True from the tap on the create button until the chat page opens
  bool isCreatingChat = false;
  late List<ChatUser> _selectedUsers;

  bool _disposed = false;
  // Number of the latest search: a slower, older one must not replace its result
  int _latestSearch = 0;

  List<ChatUser> get selectedUsers {
    return _selectedUsers;
  }

  UsersPageProvider(this._auth) {
    _selectedUsers = [];
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    getUsers();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void getUsers({String? name}) async {
    final int searchNumber = ++_latestSearch;
    _selectedUsers = [];
    users = null;
    hasError = false;
    notifyListeners();
    try {
      _database.getUsers(name: name?.trim()).then(
            (_snapshot) {
          if (_disposed || searchNumber != _latestSearch) {
            return;
          }
          users = _snapshot.docs.map(
                (_doc) {
              Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;
              _data["uid"] = _doc.id;
              return ChatUser.fromJSON(_data);
            },
          ).toList();
          // The list is for picking someone else to chat with
          users!.removeWhere((user) => user.uid == _auth.user.uid);
          notifyListeners();
        },
      ).catchError((e) {
        debugPrint("Error getting users: $e");
        if (_disposed || searchNumber != _latestSearch) {
          return;
        }
        hasError = true;
        notifyListeners();
      });
    } catch (e) {
      print("Error getting users.");
      print(e);
    }
  }

  void updateSelectedUsers(ChatUser _user) {
    if (_selectedUsers.contains(_user)) {
      _selectedUsers.remove(_user);
    } else {
      _selectedUsers.add(_user);
    }
    notifyListeners();
  }

  // Returns false when the chat could not be created
  Future<bool> createChat() async {
    if (isCreatingChat || _selectedUsers.isEmpty) {
      return true;
    }
    isCreatingChat = true;
    notifyListeners();
    bool isCreated = true;
    try {
      //Create Chat
      List<String> _membersIds =
      _selectedUsers.map((_user) => _user.uid).toList();
      _membersIds.add(_auth.user.uid);
      bool _isGroup = _selectedUsers.length > 1;
      DocumentReference? _doc = await _database.createChat(
        {
          "is_group": _isGroup,
          "is_activity": false,
          "members": _membersIds,
        },
      );
      //Navigate To Chat Page
      List<ChatUser> _members = [];
      for (var _uid in _membersIds) {
        DocumentSnapshot _userSnapshot = await _database.getUser(_uid);
        Map<String, dynamic> _userData =
        _userSnapshot.data() as Map<String, dynamic>;
        _userData["uid"] = _userSnapshot.id;
        _members.add(
          ChatUser.fromJSON(
            _userData,
          ),
        );
      }
      ChatPage _chatPage = ChatPage(
        chat: Chat(
            uid: _doc!.id,
            currentUserUid: _auth.user.uid,
            members: _members,
            messages: [],
            activity: false,
            group: _isGroup),
      );
      _selectedUsers = [];
      _navigation.navigateToPage(_chatPage);
    } catch (e) {
      print("Error creating chat.");
      print(e);
      isCreated = false;
    }
    isCreatingChat = false;
    if (!_disposed) {
      notifyListeners();
    }
    return isCreated;
  }
}
