import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey =
  new GlobalKey<NavigatorState>();

  // Clears the stack, so Back cannot return to a signed-out or signed-in page
  void removeAndNavigateToRoute(String _route) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(_route, (_) => false);
  }

  void navigateToRoute(String _route) {
    navigatorKey.currentState?.pushNamed(_route);
  }

  void navigateToPage(Widget _page) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (BuildContext _context) {
          return _page;
        },
      ),
    );
  }

  String? getCurrentRoute() {
    // The navigator sits above its routes, so the top route is read by
    // visiting it without popping anything
    String? name;
    navigatorKey.currentState?.popUntil((route) {
      name = route.settings.name;
      return true;
    });
    return name;
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }
}
