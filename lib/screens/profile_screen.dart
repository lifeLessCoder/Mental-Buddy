import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../widgets/profile_avatar.dart';
import 'dart:typed_data';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProfileAvatar(
              imageBytes: _user?.profileImage,
              radius: 100,
              onTap: _pickImage,
            ),
            const SizedBox(height: 20),
            Text(
              _user?.name ?? 'User Name',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
