import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
  final TransformationController _transformationController = TransformationController();
  List<WhiteboardObject> _objects = [];
  final GlobalKey _whiteboardKey = GlobalKey();
  bool _isEraserSelected = false;
  bool _isCrayonSelected = false;
  WhiteboardObject? _selectedObject;
  List<List<Offset>> _crayonDrawings = [];

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDrop(BuildContext context, DragTargetDetails<WhiteboardObject> details) {
    final RenderBox renderBox = _whiteboardKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.offset);

    setState(() {
      _objects.add(
        WhiteboardObject(
          position: localPosition,
          color: details.data.color,
          shape: details.data.shape,
          isResizable: details.data.isResizable,
        ),
      );
    });
  }

  void _handleTap(Offset position) {
    if (_isEraserSelected) {
      setState(() {
        _objects.removeWhere((object) {
          final rect = object.shape == BoxShape.circle
              ? Rect.fromCircle(center: object.position, radius: 15)
              : Rect.fromCenter(center: object.position, width: object.isResizable ? object.width : 30, height: object.isResizable ? object.height : 30);
          return rect.contains(position);
        });
      });
    } else if (_isCrayonSelected) {
      setState(() {
        if (_crayonDrawings.isEmpty || _crayonDrawings.last.isNotEmpty) {
          _crayonDrawings.add([]);
        }
        _crayonDrawings.last.add(position);
      });
    } else {
      bool objectTapped = false;
      for (int i = 0; i < _objects.length; i++) {
        final object = _objects[i];
        final rect = object.shape == BoxShape.circle
            ? Rect.fromCircle(center: object.position, radius: 15)
            : Rect.fromCenter(center: object.position, width: object.isResizable ? object.width : 30, height: object.isResizable ? object.height : 30);
        if (rect.contains(position)) {
          setState(() {
            _objects[i].isSelected = !_objects[i].isSelected;
            _selectedObject = _objects[i].isSelected ? _objects[i] : null;
          });
          objectTapped = true;
          break;
        }
      }
      if (!objectTapped) {
        setState(() {
          for (final object in _objects) {
            object.isSelected = false;
          }
          _selectedObject = null;
        });
      }
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_selectedObject != null) {
      setState(() {
        _selectedObject!.position += Offset(details.delta.dx, 0); // Only horizontal movement
      });
    } else if (_isCrayonSelected) {
      setState(() {
        if (_crayonDrawings.isEmpty || _crayonDrawings.last.isEmpty) {
          _crayonDrawings.add([]);
        }
        _crayonDrawings.last.add(details.localPosition);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DragTarget<WhiteboardObject>(
              onAcceptWithDetails: (details) => _handleDrop(context, details),
              builder: (context, candidateData, rejectedData) {
                return InteractiveViewer(
                  transformationController: _transformationController,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.symmetric(horizontal: 100),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Container(
                    key: _whiteboardKey,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.white,
                    child: GestureDetector(
                      onTapDown: (details) => _handleTap(details.localPosition),
                      onPanUpdate: _handlePanUpdate,
                      child: CustomPaint(
                        painter: GridPainter(_objects, _crayonDrawings),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 100,
              color: Colors.grey[300],
              child: Column(
                children: [
                  Draggable<WhiteboardObject>(
                    data: WhiteboardObject(color: Colors.red, shape: BoxShape.circle),
                    feedback: _buildDraggableItem(Colors.red, BoxShape.circle),
                    child: _buildDraggableItem(Colors.red, BoxShape.circle),
                  ),
                  Draggable<WhiteboardObject>(
                    data: WhiteboardObject(color: Colors.blue, shape: BoxShape.rectangle),
                    feedback: _buildDraggableItem(Colors.blue, BoxShape.rectangle),
                    child: _buildDraggableItem(Colors.blue, BoxShape.rectangle),
                  ),
                  Draggable<WhiteboardObject>(
                    data: WhiteboardObject(color: Colors.green, shape: BoxShape.circle),
                    feedback: _buildDraggableItem(Colors.green, BoxShape.circle),
                    child: _buildDraggableItem(Colors.green, BoxShape.circle),
                  ),
                  Draggable<WhiteboardObject>(
                    data: WhiteboardObject(color: Colors.blue.withOpacity(0.5), shape: BoxShape.rectangle, isResizable: true),
                    feedback: _buildDraggableItem(Colors.blue.withOpacity(0.5), BoxShape.rectangle, isResizable: true),
                    child: _buildDraggableItem(Colors.blue.withOpacity(0.5), BoxShape.rectangle, isResizable: true),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEraserSelected = !_isEraserSelected;
                        _isCrayonSelected = false;
                      });
                    },
                    child: _buildDraggableItem(Colors.white, BoxShape.rectangle, isResizable: false),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_isCrayonSelected) {
                          _crayonDrawings.add([]);
                        }
                        _isCrayonSelected = !_isCrayonSelected;
                        _isEraserSelected = false;
                      });
                    },
                    child: _buildDraggableItem(Colors.orange, BoxShape.rectangle, isResizable: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableItem(Color color, BoxShape shape, {bool isResizable = false}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        border: isResizable ? Border.all(color: Colors.black) : null,
      ),
    );
  }
}

class WhiteboardObject {
  Offset position;
  Color color;
  BoxShape shape;
  bool isResizable;
  double width;
  double height;
  bool isSelected;

  WhiteboardObject({
    this.position = Offset.zero,
    this.isSelected = false,
    required this.color,
    this.shape = BoxShape.circle,
    this.isResizable = false,
    this.width = 100,
    this.height = 50,
  });
}

class GridPainter extends CustomPainter {
  final List<WhiteboardObject> objects;
  final List<List<Offset>> crayonDrawings;
  GridPainter(this.objects, this.crayonDrawings);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    for (double i = 0; i <= size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i <= size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    for (final object in objects) {
      final objectPaint = Paint()..color = object.color;
      if (object.shape == BoxShape.circle) {
        canvas.drawCircle(object.position, 15, objectPaint);
      } else if (object.shape == BoxShape.rectangle) {
        if (object.isResizable) {
          final rect = Rect.fromCenter(center: object.position, width: object.width, height: object.height);
          canvas.drawRect(rect, Paint()..color = Colors.white); // Fondo blanco
          canvas.drawRect(rect, Paint()
            ..color = Colors.blue.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
          if (object.isSelected) {
            canvas.drawRect(rect, Paint()
              ..color = Colors.black
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
          }
        } else {
          final rect = Rect.fromCenter(center: object.position, width: 30, height: 30);
          canvas.drawRect(rect, objectPaint);
          if (object.isSelected) {
            canvas.drawRect(rect, Paint()
              ..color = Colors.black
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
          }
        }
      }
    }

    final crayonPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (final drawing in crayonDrawings) {
      for (int i = 0; i < drawing.length - 1; i++) {
        canvas.drawLine(drawing[i], drawing[i + 1], crayonPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
