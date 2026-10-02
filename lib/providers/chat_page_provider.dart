import 'dart:async';
import 'dart:io';

//Packages
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

//Services
import '../services/database_services.dart';
import '../services/cloud_storage_services.dart';
import '../services/media_services.dart';
import '../services/navigation_services.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/chat_message.dart';

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;

  AuthenticationProvider _auth;
  ScrollController _messagesListViewController;

  String _chatId;
  List<ChatMessage>? messages;
  bool hasError = false;
  // True while a picked image is being uploaded and sent
  bool isSendingImage = false;

  StreamSubscription? _messagesStream;
  StreamSubscription? _keyboardVisibilityStream;
  late KeyboardVisibilityController _keyboardVisibilityController;

  bool _disposed = false;
  bool _isKeyboardVisible = false;
  bool _isChatDeleted = false;

  String? _message;

  // With this:
  String? get message => _message;
  set message(String? value) {
    _message = value;
    notifyListeners(); // Ensures UI updates
  }



  ChatPageProvider(this._chatId, this._auth, this._messagesListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _keyboardVisibilityController = KeyboardVisibilityController();
    listenToMessages();
    listenToKeyboardChanges();
  }

  @override
  void dispose() {
    _disposed = true;
    _messagesStream?.cancel();
    _keyboardVisibilityStream?.cancel();
    // Leaving with the keyboard open would keep the chat marked as active
    if (_isKeyboardVisible && !_isChatDeleted) {
      _db.updateChatData(_chatId, {"is_activity": false});
    }
    super.dispose();
  }

  void listenToMessages() {
    messages = null;
    hasError = false;
    notifyListeners();
    _messagesStream?.cancel();
    try {
      _messagesStream = _db.streamMessagesForChat(_chatId).listen(
            (_snapshot) {
          try {
            List<ChatMessage> _messages = _snapshot.docs.map(
                  (_m) {
                Map<String, dynamic> _messageData =
                _m.data() as Map<String, dynamic>;

                return ChatMessage.fromJSON(_messageData);
              },
            ).toList();
            messages = _messages;
            hasError = false;
          } catch (e) {
            debugPrint("Error reading messages: $e");
            hasError = true;
          }
          notifyListeners();
          WidgetsBinding.instance.addPostFrameCallback(
                (_) {
              if (_messagesListViewController.hasClients) {
                _messagesListViewController.jumpTo(
                    _messagesListViewController.position.maxScrollExtent);
              }
            },
          );
        },
        onError: (e) {
          debugPrint("Error getting messages: $e");
          hasError = true;
          notifyListeners();
        },
      );
    } catch (e) {
      print("Error getting messages.");
      print(e);
      hasError = true;
      notifyListeners();
    }
  }

  void listenToKeyboardChanges() {
    _keyboardVisibilityStream = _keyboardVisibilityController.onChange.listen(
          (_event) {
        _isKeyboardVisible = _event;
        _db.updateChatData(_chatId, {"is_activity": _event});
      },
    );
  }

  void sendTextMessage() {
    if (_message != null && _message!.trim().isNotEmpty) {
      ChatMessage _messageToSend = ChatMessage(
        content: _message!,
        type: MessageType.TEXT,
        senderID: _auth.user.uid,
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(_chatId, _messageToSend);
    }
  }

  // Returns false when the picked image could not be uploaded
  Future<bool> sendImageMessage() async {
    bool isSent = true;
    try {
      PlatformFile? picked = await _media.pickImageFromLibrary();

      if (picked != null && picked.path != null) {
        File file = File(picked.path!); // Convert PlatformFile to File

        isSendingImage = true;
        notifyListeners();

        String? _downloadURL = await _storage.saveChatImageToStorage(file, _chatId, _auth.user.uid);

        if (_downloadURL != null) {
          ChatMessage _messageToSend = ChatMessage(
            content: _downloadURL,
            type: MessageType.IMAGE,
            senderID: _auth.user.uid,
            sentTime: DateTime.now(),
          );
          _db.addMessageToChat(_chatId, _messageToSend);
        } else {
          isSent = false;
        }
      }
    } catch (e) {
      print("Error sending image message: $e");
      isSent = false;
    }
    isSendingImage = false;
    if (!_disposed) {
      notifyListeners();
    }
    return isSent;
  }

  void deleteChat() {
    _isChatDeleted = true;
    goBack();
    _db.deleteChat(_chatId);
  }

  void goBack() {
    _navigation.goBack();
  }
}
