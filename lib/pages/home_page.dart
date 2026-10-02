//Packages
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

//Pages
import '../pages/chats_page.dart';
import '../pages/users_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    final List<Widget> pages = [
      // The empty chats list offers a shortcut to the Users tab
      ChatsPage(onFindUsers: () => _showPage(1)),
      const UsersPage(),
    ];
    return Scaffold(
      body: pages[_currentPage],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPage,
        onDestinationSelected: _showPage,
        destinations: [
          NavigationDestination(
            label: context.tr('chats'),
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble),
          ),
          NavigationDestination(
            label: context.tr('users'),
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
          ),
        ],
      ),
    );
  }

  void _showPage(int index) {
    setState(() {
      _currentPage = index;
    });
  }
}
