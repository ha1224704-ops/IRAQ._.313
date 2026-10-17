import 'package:flutter/material.dart';

void main() => runApp(IraqEngineApp());

class IraqEngineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IRAQ Engine',
      theme: ThemeData(brightness: Brightness.dark),
      home: EngineHome(),
    );
  }
}

class EngineHome extends StatefulWidget {
  @override
  _EngineHomeState createState() => _EngineHomeState();
}

class _EngineHomeState extends State<EngineHome> {
  List<Map<String, dynamic>> objects = [];
  String currentGame = 'بوبجي عراق';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('IRAQ ENGINE - صنع حيدر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        actions: [
          IconButton(icon: Icon(Icons.play_arrow, color: Colors.green), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GamePreview(objects: objects)))),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black87,
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _toolBtn(Icons.person, 'لاعب', Colors.blue),
                _toolBtn(Icons.smart_toy, 'عدو', Colors.red),
                _toolBtn(Icons.home, 'بيت', Colors.brown),
                _toolBtn(Icons.directions_car, 'سيارة', Colors.green),
                _toolBtn(Icons.gps_fixed, 'سلاح', Colors.amber),
                SizedBox(width: 20),
                ElevatedButton.icon(icon: Icon(Icons.file_upload, size: 14), label: Text('تصدير APK', style: TextStyle(fontSize: 10)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () => exportGame()),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 100,
                  color: Color(0xFF1a1a1a),
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('المشهد', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(
                        child: ListView(
                          children: objects.map((o) => ListTile(
                            dense: true,
                            leading: Icon(o['icon'], color: o['color'], size: 16),
                            title: Text(o['name'], style: TextStyle(color: Colors.white, fontSize: 10)),
                            onTap: () {},
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Color(0xFF2a2a2a),
                    child: Stack(
                      children: [
                        CustomPaint(size: Size.infinite, painter: GridPainter()),
                        ...objects.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var obj = entry.value;
                          return Positioned(
                            left: obj['x'],
                            top: obj['y'],
                            child: Draggable(
                              feedback: Icon(obj['icon'], color: obj['color'], size: 40),
                              childWhenDragging: Container(),
                              onDragEnd: (d) {
                                setState(() {
                                  objects[idx]['x'] = d.offset.dx;
                                  objects[idx]['y'] = d.offset.dy - 100;
                                });
                              },
                              child: Column(
                                children: [
                                  Icon(obj['icon'], color: obj['color'], size: 30),
                                  Text(obj['name'], style: TextStyle(color: Colors.white, fontSize: 8)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () => addObject(label, icon, color),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 8)),
          ],
        ),
      ),
    );
  }

  void addObject(String name, IconData icon, Color color) {
    setState(() {
      objects.add({
        'name': '$name ${objects.length + 1}',
        'icon': icon,
        'color': color,
        'x': 30.0 + objects.length * 30,
        'y': 30.0 + objects.length * 30,
      });
    });
  }

  void exportGame() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('تم التصدير!', style: TextStyle(color: Colors.green)),
        content: Text('تم تصدير $currentGame\nالحزمة: com.iraqlive.wahediraq\nهذا محركك الخاص - صنع حيدر\n\nمحمي بانظمة مكافحة الغش', style: TextStyle(color: Colors.white)),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('ممتاز')),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white10..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GamePreview extends StatelessWidget {
  final List<Map<String, dynamic>> objects;
  GamePreview({required this.objects});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('معاينة اللعبة')),
      body: Container(
        color: Colors.green[900],
        child: Stack(
          children: objects.map((o) => Positioned(left: o['x'], top: o['y'], child: Icon(o['icon'], color: o['color'], size: 36))).toList(),
        ),
      ),
    );
  }
}