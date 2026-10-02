import 'dart:async';

//Packages
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/database_services.dart';

//Models
import '../models/chat_user.dart';
import '../services/navigation_services.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;
  late final StreamSubscription _authStateStream;

  late ChatUser user;

  // Translation key of the last failed login or registration, null after a success
  String? errorKey;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();

    _authStateStream = _auth.authStateChanges().listen((_user) {
      if (_user != null) {
        _databaseService.updateUserLastSeenTime(_user.uid);
        _databaseService.getUser(_user.uid).then(
              (_snapshot) {
            Map<String, dynamic>? _userData =
            _snapshot.data() as Map<String, dynamic>?;
            // No profile document yet: the account is still being registered
            if (_userData == null) {
              return;
            }
            user = ChatUser.fromJSON(
              {
                "uid": _user.uid,
                "name": _userData["name"],
                "email": _userData["email"],
                "last_active": _userData["last_active"],
                "image": _userData["image"],
              },
            );
            _navigationService.removeAndNavigateToRoute('/home');
          },
        ).catchError((e) {
          debugPrint(e.toString());
        });
      } else {
        // The register page signs out and in again on its own while it works
        String? route = _navigationService.getCurrentRoute();
        if (route != '/login' && route != '/register') {
          _navigationService.removeAndNavigateToRoute('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _authStateStream.cancel();
    super.dispose();
  }

  Future<void> loginUsingEmailAndPassword(
      String _email, String _password) async {
    errorKey = null;
    try {
      await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
    } on FirebaseAuthException catch (e) {
      print("Error logging user into Firebase");
      errorKey = _errorKeyFor(e);
    } catch (e) {
      print(e);
      errorKey = 'auth_error_generic';
    }
  }

  Future<String?> registerUserUsingEmailAndPassword(
      String _email, String _password) async {
    errorKey = null;
    try {
      UserCredential _credentials = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      return _credentials.user!.uid;
    } on FirebaseAuthException catch (e) {
      print("Error registering user.");
      errorKey = _errorKeyFor(e);
    } catch (e) {
      print(e);
      errorKey = 'auth_error_generic';
    }
    return null;
  }

  // Removes an account whose registration could not be completed, so the
  // same email can be used to try again
  Future<void> deleteCurrentUser() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }

  String _errorKeyFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'invalid-email':
      case 'wrong-password':
      case 'user-not-found':
        return 'auth_error_credentials';
      case 'email-already-in-use':
        return 'auth_error_email_in_use';
      case 'weak-password':
        return 'auth_error_weak_password';
      case 'network-request-failed':
        return 'auth_error_network';
      case 'too-many-requests':
        return 'auth_error_too_many';
      default:
        return 'auth_error_generic';
    }
  }
}
