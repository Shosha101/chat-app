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

    if (_recepients.isEmpty) {
      print("Recepients list is empty! Adding current user.");
      _recepients.add(members.firstWhere((m) => m.uid == currentUserUid));
    }
  }


  List<ChatUser> recepients() {
    return _recepients;
  }

  String title() {
    if (_recepients.isNotEmpty) {
      return !group
          ? _recepients.first.name
          : _recepients.map((_user) => _user.name).join(", ");
    } else {
      return "You"; // Default title for self-chat
    }
  }

  String imageURL() {
    if (_recepients.isNotEmpty) {
      return !group
          ? _recepients.first.imageURL // Get recipient's image
          : "https://e7.pngegg.com/pngimages/380/670/png-clipart-group-chat-logo-blue-area-text-symbol-metroui-apps-live-messenger-alt-2-blue-text.png";
    } else {
      print("Recepients list is empty! Using current user's image.");
      return members.firstWhere(
              (m) => m.uid == currentUserUid,
          orElse: () => members.first // Fallback to first member
      ).imageURL;
    }
  }


}