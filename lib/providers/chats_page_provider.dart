import 'dart:async';

//Packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Services
import '../services/database_services.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';

class ChatsPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;

  late DatabaseService _db;

  List<Chat>? chats;
  bool hasError = false;

  StreamSubscription? _chatsStream;
  bool _disposed = false;
  // Number of the latest snapshot: an older one that finishes loading late is dropped
  int _latestSnapshot = 0;

  ChatsPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
    getChats();
  }

  @override
  void dispose() {
    _disposed = true;
    _chatsStream?.cancel();
    super.dispose();
  }

  void getChats() async {
    chats = null;
    hasError = false;
    notifyListeners();
    _chatsStream?.cancel();
    try {
      _chatsStream =
          _db.getChatsForUser(_auth.user.uid).listen((_snapshot) async {
            final int snapshotNumber = ++_latestSnapshot;
            try {
              final List<Chat> loaded = await Future.wait(
                _snapshot.docs.map(
                      (_d) async {
                    Map<String, dynamic> _chatData =
                    _d.data() as Map<String, dynamic>;
                    //Get Users In Chat
                    List<ChatUser> _members = [];
                    for (var _uid in _chatData["members"] ?? []) {
                      DocumentSnapshot _userSnapshot = await _db.getUser(_uid);
                      Map<String, dynamic>? _userData =
                      _userSnapshot.data() as Map<String, dynamic>?;
                      // A member whose profile no longer exists is left out
                      if (_userData == null) {
                        continue;
                      }
                      _userData["uid"] = _userSnapshot.id;
                      _members.add(
                        ChatUser.fromJSON(_userData),
                      );
                    }

                    //Get Last Message For Chat
                    List<ChatMessage> _messages = [];
                    QuerySnapshot _chatMessage =
                    await _db.getLastMessageForChat(_d.id);
                    if (_chatMessage.docs.isNotEmpty) {
                      Map<String, dynamic> _messageData =
                      _chatMessage.docs.first.data()! as Map<String, dynamic>;
                      ChatMessage _message = ChatMessage.fromJSON(_messageData);
                      _messages.add(_message);
                    }
                    //Return Chat Instance
                    return Chat(
                      uid: _d.id,
                      currentUserUid: _auth.user.uid,
                      members: _members,
                      messages: _messages,
                      activity: _chatData["is_activity"] ?? false,
                      group: _chatData["is_group"] ?? false,
                    );
                  },
                ).toList(),
              );
              if (_disposed || snapshotNumber != _latestSnapshot) {
                return;
              }
              chats = loaded;
              hasError = false;
              notifyListeners();
            } catch (e) {
              debugPrint("Error reading chats: $e");
              _showError();
            }
          }, onError: (e) {
            debugPrint("Error getting chats: $e");
            _showError();
          });
    } catch (e) {
      print("Error getting chats.");
      print(e);
      _showError();
    }
  }

  void _showError() {
    if (_disposed) {
      return;
    }
    hasError = true;
    notifyListeners();
  }
}
