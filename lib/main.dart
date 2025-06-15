import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/drawer_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  await Hive.openBox<Habit>('essentialsHabits');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      home: MyHomePage(
        title: 'Mental Buddy',
        onThemeColorChanged: _handleThemeColorChanged,
        onDarkModeChanged: _handleDarkModeChanged,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.onThemeColorChanged,
    required this.onDarkModeChanged,
  });

  final String title;
  final Function(Color) onThemeColorChanged;
  final Function(bool) onDarkModeChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  bool done = false;

  Habit({required this.title});

  // Hive serialization
  Habit.fromJson(Map<String, dynamic> json)
    : title = json['title'],
      done = json['done'] ?? false;

  Map<String, dynamic> toJson() => {'title': title, 'done': done};
}

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return Habit.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer.writeMap(obj.toJson());
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late Box<Habit> _habitBox;
  final TextEditingController _habitController = TextEditingController();
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _habitBox = Hive.box<Habit>('essentialsHabits');
  }

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }

  List<Habit> get essentialsHabitList => _habitBox.values.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Icon(Icons.hail_rounded),
        actions: [
          IconButton(
            icon: Icon(Icons.anchor),
            onPressed: () => print('Essentials Action button pressed'),
          ),
          IconButton(
            icon: Icon(Icons.emoji_emotions),
            onPressed: () => print('Pleasurables Action button pressed'),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Material(
              elevation: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.anchor, size: 48),
                  SizedBox(width: 8),
                  Text('Essentials', style: TextStyle(fontSize: 48)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  type: MaterialType.card,
                  child: ValueListenableBuilder(
                    valueListenable: _habitBox.listenable(),
                    builder: (context, Box<Habit> box, _) {
                      final habits = box.values.toList();
                      // Sort: unchecked first, then checked
                      habits.sort((a, b) {
                        if (a.done == b.done) return 0;
                        return a.done ? 1 : -1;
                      });
                      return ListView(
                        children: habits
                            .map(
                              (habit) => CheckboxListTile(
                                value: habit.done,
                                title: Text(
                                  habit.title,
                                  style: TextStyle(
                                    decoration: habit.done
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: habit.done
                                        ? Colors.grey.withAlpha(
                                            (0.75 * 255).toInt(),
                                          )
                                        : null,
                                  ),
                                ),
                                selected: habit.done,
                                onChanged: (value) {
                                  habit.done = value ?? false;
                                  habit.save();
                                },
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newHabit = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add New Habit'),
                content: TextField(
                  controller: _habitController,
                  autofocus: true,
                  decoration: InputDecoration(hintText: 'Enter habit name'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      final text = _habitController.text.trim();
                      Navigator.of(context).pop(text.isNotEmpty ? text : null);
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
          if (newHabit != null && newHabit.isNotEmpty) {
            _habitBox.add(Habit(title: newHabit));
            _habitController.clear();
          } else {
            _habitController.clear();
          }
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
          ],
        ),
      ),
      drawer: DrawerMenu(
        onThemeColorChanged: widget.onThemeColorChanged,
        onDarkModeChanged: widget.onDarkModeChanged,
      ),
    );
  }
}
