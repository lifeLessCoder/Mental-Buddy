import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mental_buddy/mental_buddy_app.dart';
import 'models/user.dart';
import 'models/habit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<Habit>('essentialsHabits');
  await Hive.openBox<User>('userBox');
  runApp(const MentalBuddyApp());
}