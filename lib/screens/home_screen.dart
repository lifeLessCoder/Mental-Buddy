import 'dart:convert';
import 'dart:io' show Platform;
import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mental_buddy/models/habit.dart';
import 'package:mental_buddy/widgets/drawer_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.title,
    required this.onThemeColorChanged,
    required this.onDarkModeChanged,
  });

  final String title;
  final Function(Color) onThemeColorChanged;
  final Function(bool) onDarkModeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          OpenContainer(
            transitionDuration: Duration(milliseconds: 300),
            transitionType: ContainerTransitionType.fadeThrough,
            closedColor: Colors.transparent,
            closedElevation: 0,
            openColor: Colors.transparent,
            closedBuilder: (context, openContainer) {
              return IconButton(
                icon: Icon(Icons.emoji_emotions),
                onPressed: openContainer,
              );
            },
            openBuilder: (context, closeContainer) =>
                _getAffirmationDialog(closeContainer),
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
                              (habit) => Dismissible(
                                key: ValueKey(habit.key),
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  final String habitTitle = habit.title;
                                  habit.delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Item "$habitTitle" deleted',
                                      ),
                                    ),
                                  );
                                },
                                child: CheckboxListTile(
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
                                  secondary:
                                      ((!kIsWeb &&
                                              (Platform.isAndroid ||
                                                  Platform.isIOS)) ||
                                          (kIsWeb &&
                                              (defaultTargetPlatform ==
                                                      TargetPlatform.android ||
                                                  defaultTargetPlatform ==
                                                      TargetPlatform.iOS)))
                                      ? null
                                      : IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            final String habitTitle =
                                                habit.title;
                                            await habit.delete();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Item "$habitTitle" deleted',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
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
      floatingActionButton: OpenContainer(
        transitionDuration: Duration(milliseconds: 300),
        closedShape: const RoundedRectangleBorder(),
        closedColor: Colors.transparent,
        closedElevation: 0,
        openColor: Colors.transparent,
        // openElevation: 0,
        transitionType: ContainerTransitionType.fadeThrough,
        closedBuilder: (context, openContainer) {
          return FloatingActionButton(
            onPressed: openContainer,
            child: Icon(Icons.add),
          );
        },
        openBuilder: (context, closeContainer) {
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
                  closeContainer();
                  _habitController.clear();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final text = _habitController.text.trim();
                  if (text.isNotEmpty) {
                    _habitBox.add(Habit(title: text));
                  }
                  closeContainer();
                  _habitController.clear();
                },
                child: Text('Add'),
              ),
            ],
          );
        },
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

  Future<String> _getRandomAffirmation() async {
    final String jsonString = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/affirmations.json');
    final List<String> affirmations =
        (json.decode(jsonString) as Map<String, dynamic>)['affirmations']!
            .cast<String>();
    affirmations.shuffle();
    return affirmations.isNotEmpty
        ? affirmations.first
        : 'You are doing great!';
  }

  Widget _getAffirmationDialog(void Function() closeContainer) {
    return AlertDialog(
      title: Text(
        'Affirmation for you! 😃',
        style: TextStyle(fontWeight: FontWeight.w100),
      ),
      content: FutureBuilder<String>(
        future: _getRandomAffirmation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LinearProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Text(
              snapshot.data ?? 'You are doing great! 💪',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            );
          }
        },
      ),
      actions: [TextButton(onPressed: closeContainer, child: Text('Close'))],
    );
  }
}
