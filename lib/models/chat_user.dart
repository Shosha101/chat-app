import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String uid;
  final String email;
  final String name;
  final String imageURL;
  late DateTime lastActive;

  ChatUser(
      {required this.uid,
      required this.email,
      required this.name,
      required this.imageURL,
      required this.lastActive});

  factory ChatUser.fromJSON(Map<String, dynamic> _json) {
    return ChatUser(
      uid: _json["uid"] ?? "",
      email: _json["email"] ?? "No Email",
      name: _json["name"] ?? "No Name",
      imageURL: _json["image"] ?? "No Image",
      lastActive: _json["last_active"] != null
          ? (_json["last_active"] as Timestamp).toDate()
          : DateTime.now().toUtc(),
    );
  }
  Map<String, dynamic> toMap(){
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "imgURL": imageURL,
      "lastActive": lastActive.toIso8601String()
    };
  }
 String lastDayActive(){
    return "${lastActive.month}/${lastActive.day}/${lastActive.year}";
 }
 bool wasRecentlyActive(){
    return  DateTime.now().difference(lastActive).inHours<2;
 }
}
