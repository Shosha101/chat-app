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

  late StreamSubscription _messagesStream;
  late StreamSubscription _keyboardVisibilityStream;
  late KeyboardVisibilityController _keyboardVisibilityController;

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
    _messagesStream.cancel();
    super.dispose();
  }

  void listenToMessages() {
    try {
      _messagesStream = _db.streamMessagesForChat(_chatId).listen(
            (_snapshot) {
          List<ChatMessage> _messages = _snapshot.docs.map(
                (_m) {
              Map<String, dynamic> _messageData =
              _m.data() as Map<String, dynamic>;

              return ChatMessage.fromJSON(_messageData);
            },
          ).toList();
          messages = _messages;
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
      );
    } catch (e) {
      print("Error getting messages.");
      print(e);
    }
  }

  void listenToKeyboardChanges() {
    _keyboardVisibilityStream = _keyboardVisibilityController.onChange.listen(
          (_event) {
        _db.updateChatData(_chatId, {"is_activity": _event});
      },
    );
  }

  void sendTextMessage() {
    if (_message != null) {
      ChatMessage _messageToSend = ChatMessage(
        content: _message!,
        type: MessageType.TEXT,
        senderID: _auth.user.uid,
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(_chatId, _messageToSend);
    }
  }

  void sendImageMessage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image, // Ensure only images are picked
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!); // Convert PlatformFile to File

        String? _downloadURL = await _storage.saveChatImageToStorage(file, _chatId, _auth.user.uid);

        if (_downloadURL != null) {
          ChatMessage _messageToSend = ChatMessage(
            content: _downloadURL,
            type: MessageType.IMAGE,
            senderID: _auth.user.uid,
            sentTime: DateTime.now(),
          );
          _db.addMessageToChat(_chatId, _messageToSend);
        }
      }
    } catch (e) {
      print("Error sending image message: $e");
    }
  }

  void deleteChat() {
    goBack();
    _db.deleteChat(_chatId);
  }

  void goBack() {
    _navigation.goBack();
  }
}