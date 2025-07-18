import 'dart:convert';
import 'dart:io' show Platform;
import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mental_buddy/models/habit.dart';
import 'package:mental_buddy/widgets/drawer_menu.dart';
import 'package:mental_buddy/screens/journey_path_view.dart';

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
  DateTime? _selectedDueDateTime;
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  static final _dueDateFormat = DateFormat('EEE, MMM d, yyyy h:mma');
  static final _checkedItemTextColor = Colors.grey.withAlpha(
    (0.75 * 255).toInt(),
  );

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
                                direction: DismissDirection.endToStart,
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
                                          ? _checkedItemTextColor
                                          : null,
                                    ),
                                  ),
                                  subtitle: habit.dueDateTime != null
                                      ? Builder(
                                          builder: (context) {
                                            final double? titleFontSize =
                                                DefaultTextStyle.of(
                                                  context,
                                                ).style.fontSize;
                                            final double subtitleFontSize =
                                                (titleFontSize ?? 16) * 0.6;
                                            return Row(
                                              children: [
                                                Chip(
                                                  label: Text(
                                                    _dueDateFormat.format(
                                                      habit.dueDateTime!,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize:
                                                          subtitleFontSize,
                                                      color:
                                                          habit.dueDateTime!
                                                              .isBefore(
                                                                DateTime.now(),
                                                              )
                                                          ? Colors.redAccent
                                                          : Colors.greenAccent,
                                                    ),
                                                  ),
                                                  // avatar: Icon(Icons.alarm),
                                                  shadowColor:
                                                      habit.dueDateTime!
                                                          .isBefore(
                                                            DateTime.now(),
                                                          )
                                                      ? Colors.redAccent
                                                      : Colors.greenAccent,
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                      : null,
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
            onPressed: () {
              _selectedDueDateTime = null; // Reset on open
              openContainer();
            },
            child: Icon(Icons.add),
          );
        },
        openBuilder: (context, closeContainer) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Add New Habit'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _habitController,
                      autofocus: true,
                      decoration: InputDecoration(hintText: 'Enter habit name'),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDueDateTime == null
                                ? 'No due date selected'
                                : 'Due: '
                                      '${_dueDateFormat.format(_selectedDueDateTime!)}',
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            final now = DateTime.now();
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: now,
                              firstDate: now,
                              lastDate: DateTime(now.year + 5),
                            );
                            if (pickedDate != null) {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                              if (pickedTime != null) {
                                final DateTime combined = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                setState(() {
                                  _selectedDueDateTime = combined;
                                });
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      closeContainer();
                      _habitController.clear();
                      _selectedDueDateTime = null;
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      final text = _habitController.text.trim();
                      if (text.isNotEmpty) {
                        _habitBox.add(
                          Habit(title: text, dueDateTime: _selectedDueDateTime),
                        );
                      }
                      closeContainer();
                      _habitController.clear();
                      _selectedDueDateTime = null;
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
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
            IconButton(
              icon: Icon(Icons.route),
              tooltip: 'Journey',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => JourneyPathView(),
                  ),
                );
              },
            ),
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
