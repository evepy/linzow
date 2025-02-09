import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const WhiteboardApp());
}

class WhiteboardApp extends StatelessWidget {
  const WhiteboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Whiteboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WhiteboardScreen(),
    );
  }
}

class WhiteboardScreen extends StatefulWidget {
  const WhiteboardScreen({super.key});

  @override
  WhiteboardScreenState createState() => WhiteboardScreenState();
}

class WhiteboardScreenState extends State<WhiteboardScreen> {
  List<String> levels = [
    'Start',
    'Level-1',
    'Level-2',
    'Level-3',
    'Level-4',
    'Level-5'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: CustomPaint(
              painter: DashLinePainter(),
              child: GridView.builder(
                itemCount: levels.length,
                reverse: true,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1, childAspectRatio: 2),
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    mainAxisAlignment: (index % 2 == 0)
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          height: 125,
                          width: 125,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(62.5),
                          ),
                          child: Center(
                            child: Container(
                              height: 110,
                              width: 110,
                              decoration: BoxDecoration(
                                color: (index == 0)
                                    ? Colors.green
                                    : Colors.amberAccent,
                                borderRadius: BorderRadius.circular(55),
                              ),
                              child: Center(
                                child: Text(levels[index],
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
      
    );
    
  }
  
}

class DashLinePainter extends CustomPainter {
  final Paint _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path()
      ..moveTo(size.width / 4.5, size.height / 1.09)
      ..lineTo(size.width / 4.5, size.height / 1.28)
      ..arcToPoint(Offset(size.width / 3.2, size.height / 1.33),
          radius: const Radius.circular(50), clockwise: true)
      ..lineTo(size.width / 1.3, size.height / 1.33)
      ..lineTo(size.width / 1.3, size.height / 1.62)
      ..arcToPoint(Offset(size.width / 1.5, size.height / 1.72),
          radius: const Radius.circular(50), clockwise: false)
      ..lineTo(size.width / 4.5, size.height / 1.72)
      ..lineTo(size.width / 4.5, size.height / 2.2)
      ..arcToPoint(Offset(size.width / 3, size.height / 2.4),
          radius: const Radius.circular(50), clockwise: true)
      ..lineTo(size.width / 1.3, size.height / 2.4)
      ..lineTo(size.width / 1.3, size.height / 3.5)
      ..arcToPoint(Offset(size.width / 1.45, size.height / 4),
          radius: const Radius.circular(50), clockwise: false)
      ..lineTo(size.width / 4.5, size.height / 4)
      ..lineTo(size.width / 4.5, size.height / 8.5)
      ..arcToPoint(Offset(size.width / 3.2, size.height / 11),
          radius: const Radius.circular(50), clockwise: true)
      ..lineTo(size.width / 1.3, size.height / 11);

    Path dashPath = Path();

    double dashWidth = 10.0;
    double dashSpace = 5.0;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    canvas.drawPath(dashPath, _paint);
  }

  @override
  bool shouldRepaint(DashLinePainter oldDelegate) => true;
}