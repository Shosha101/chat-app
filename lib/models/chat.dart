import '../models/chat_user.dart';
import '../models/chat_message.dart';

class Chat {
  final String uid;
  final String currentUserUid;
  final bool activity;
  final bool group;
  final List<ChatUser> members;
  List<ChatMessage> messages;

  late final List<ChatUser> _recepients;

  Chat({
    required this.uid,
    required this.currentUserUid,
    required this.members,
    required this.messages,
    required this.activity,
    required this.group,
  }) {
    _recepients = members.where((_i) => _i.uid != currentUserUid).toList();

    // A chat with only the current user in it: show the user's own profile
    if (_recepients.isEmpty) {
      _recepients.addAll(members.where((m) => m.uid == currentUserUid).take(1));
    }
  }


  List<ChatUser> recepients() {
    return _recepients;
  }

  // Empty for a group chat: the UI draws a group avatar of its own
  String imageURL() {
    if (group || _recepients.isEmpty) {
      return "";
    }
    return _recepients.first.imageURL;
  }


}
