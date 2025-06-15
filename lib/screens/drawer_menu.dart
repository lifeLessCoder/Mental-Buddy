import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class DrawerMenu extends StatelessWidget {
  final Function(Color) onThemeColorChanged;
  final Function(bool) onDarkModeChanged;

  const DrawerMenu({
    super.key,
    required this.onThemeColorChanged,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.face, size: 40),
                ),
                SizedBox(height: 10),
                Text(
                  'Mental Buddy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeColorChanged: onThemeColorChanged,
                    onDarkModeChanged: onDarkModeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
