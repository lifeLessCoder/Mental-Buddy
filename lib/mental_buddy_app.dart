import 'package:flutter/material.dart';
import 'package:mental_buddy/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class MentalBuddyApp extends StatefulWidget {
  const MentalBuddyApp({super.key});

  @override
  State<MentalBuddyApp> createState() => _MentalBuddyAppState();
}

class _MentalBuddyAppState extends State<MentalBuddyApp> {
  Color _themeColor = Colors.cyan;
  bool _isDarkMode = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeColor = Color(_prefs.getInt('themeColor') ?? Colors.cyan.value);
      _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _handleThemeColorChanged(Color color) {
    setState(() => _themeColor = color);
  }

  void _handleDarkModeChanged(bool isDarkMode) {
    setState(() => _isDarkMode = isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental budddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _themeColor,
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        title: 'Mental Buddy',
        onThemeColorChanged: _handleThemeColorChanged,
        onDarkModeChanged: _handleDarkModeChanged,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}