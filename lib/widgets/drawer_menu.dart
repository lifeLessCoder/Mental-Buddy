import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import 'profile_avatar.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';

class DrawerMenu extends StatefulWidget {
  final Function(Color) onThemeColorChanged;
  final Function(bool) onDarkModeChanged;

  const DrawerMenu({
    super.key,
    required this.onThemeColorChanged,
    required this.onDarkModeChanged,
  });

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  late Box<User> _userBox;
  User? _user;

  @override
  void initState() {
    super.initState();
    _userBox = Hive.box<User>('userBox');
    _user = _userBox.get('user') ?? User(name: 'User Name');
    if (_userBox.get('user') == null) {
      _userBox.put('user', _user!);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _user = _user!..profileImage = bytes;
        _userBox.put('user', _user!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileAvatar(
                  imageBytes: _user?.profileImage,
                  radius: 40,
                  onTap: _pickImage,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mental Buddy',
                  style: TextStyle(color: Colors.white, fontSize: 20),
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
                    onThemeColorChanged: widget.onThemeColorChanged,
                    onDarkModeChanged: widget.onDarkModeChanged,
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
