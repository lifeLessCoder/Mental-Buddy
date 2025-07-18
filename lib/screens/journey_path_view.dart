import 'package:flutter/material.dart';
import 'dart:ui';

// 1. Data Model and Hardcoded List

enum JourneyStatus { locked, unlocked, completed }

class JourneyItem {
  final int id;
  final String title;
  final JourneyStatus status;

  JourneyItem({required this.id, required this.title, required this.status});
}

// Hardcoded journey items
final List<JourneyItem> journeyItems = [
  JourneyItem(id: 1, title: 'Basics 1', status: JourneyStatus.completed),
  JourneyItem(id: 2, title: 'Greetings', status: JourneyStatus.completed),
  JourneyItem(id: 3, title: 'People', status: JourneyStatus.unlocked),
  JourneyItem(id: 4, title: 'Travel', status: JourneyStatus.locked),
  JourneyItem(id: 5, title: 'Food', status: JourneyStatus.locked),
  JourneyItem(id: 6, title: 'Family', status: JourneyStatus.locked),
];

// 2. The Overall Structure
class JourneyPathView extends StatefulWidget {
  const JourneyPathView({Key? key}) : super(key: key);

  @override
  State<JourneyPathView> createState() => _JourneyPathViewState();
}

class _JourneyPathViewState extends State<JourneyPathView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 800, // Adjust as needed
        child: Stack(
          children: [
            // 3. Drawing the S-Shaped Path
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 800),
              painter: PathPainter(),
            ),
            // 4. Positioning Items on the Path
            ..._buildJourneyItems(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildJourneyItems(BuildContext context) {
    final double itemSize = 56;
    final path = PathPainter.createSPath(MediaQuery.of(context).size.width, 800);
    final metrics = path.computeMetrics().first;
    final List<Widget> widgets = [];
    for (int i = 0; i < journeyItems.length; i++) {
      final distance = metrics.length / (journeyItems.length + 1) * (i + 1);
      final tangent = metrics.getTangentForOffset(distance);
      if (tangent == null) continue;
      final pos = tangent.position;
      final item = journeyItems[i];
      widgets.add(Positioned(
        left: pos.dx - itemSize / 2,
        top: pos.dy - itemSize / 2,
        child: _buildJourneyItem(item, itemSize),
      ));
    }
    return widgets;
  }

  Widget _buildJourneyItem(JourneyItem item, double size) {
    Color color;
    IconData icon;
    switch (item.status) {
      case JourneyStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case JourneyStatus.unlocked:
        color = Colors.blue;
        icon = Icons.radio_button_checked;
        break;
      case JourneyStatus.locked:
        color = Colors.grey;
        icon = Icons.lock;
        break;
    }
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.status == JourneyStatus.locked ? null : () {},
            borderRadius: BorderRadius.circular(size / 2),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, color: color, size: size * 0.6),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(item.title, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// 3. PathPainter for S-shaped path
class PathPainter extends CustomPainter {
  static Path createSPath(double width, double height) {
    final path = Path();
    final double w = width;
    final double h = height;
    path.moveTo(w / 2, 40);
    path.cubicTo(
      w * 0.8, h * 0.2,
      w * 0.2, h * 0.4,
      w / 2, h * 0.5,
    );
    path.cubicTo(
      w * 0.8, h * 0.6,
      w * 0.2, h * 0.8,
      w / 2, h - 40,
    );
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = createSPath(size.width, size.height);
    final paint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
