
import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Colors.black,
      indicatorColor: Colors.transparent,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined, color: Colors.white70),
          selectedIcon: Icon(Icons.home, color: Colors.blueAccent),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined, color: Colors.white70),
          selectedIcon: Icon(Icons.search, color: Colors.blueAccent),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.upload_file_outlined, color: Colors.white70),
          selectedIcon: Icon(Icons.upload_file, color: Colors.blueAccent),
          label: 'Upload',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_awesome_outlined, color: Colors.white70),
          selectedIcon: Icon(Icons.auto_awesome, color: Colors.blueAccent),
          label: 'AI',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline, color: Colors.white70),
          selectedIcon: Icon(Icons.person, color: Colors.blueAccent),
          label: 'Profile',
        ),
      ],
    );
  }
}
