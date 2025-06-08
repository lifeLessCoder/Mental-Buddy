import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental budddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),
      home: const MyHomePage(title: 'Mental Buddy'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Habit {
  final String title;
  bool done = false;

  Habit({required this.title});
}

class _MyHomePageState extends State<MyHomePage> {
  final Set<Habit> essentialsHabitSet = [
    'Sleep 7-8 hrs',
    'Take Meds',
    'Water - 2L',
    'Food 5 times',
    'Exercise - 30 mins',
    'Meditate - 30 mins',
    'Brush',
    'Shower',
  ].map((habit) => Habit(title: habit)).toSet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // mainAxisSize: MainAxisSize.min,
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
                  child: ListView(
                    children: essentialsHabitSet
                        .map(
                          (habit) => CheckboxListTile(
                            value: habit.done,
                            title: Text(habit.title),
                            selected: habit.done,
                            onChanged: (value) {
                              setState(() {
                                habit.done = value ?? false;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
