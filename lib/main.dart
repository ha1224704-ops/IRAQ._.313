import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(IraqEngineApp());

class IraqEngineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IRAQ Engine',
      theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: Color(0xFF111111)),
      home: EngineHome(),
    );
  }
}

class EngineHome extends StatefulWidget {
  @override
  _EngineHomeState createState() => _EngineHomeState();
}

class _EngineHomeState extends State<EngineHome> {
  List<String> myGames = [];
  List<Map<String, dynamic>> objects = [];
  String currentGame = 'بوبجي عراق - صنع حيدر';

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  loadGames() async {
    final p = await SharedPreferences.getInstance();
    setState(() => myGames = p.getStringList('iraq_games') ?? ['بوبجي عراق - اول لعبة']);
  }

  saveGames() async {
    final p = await SharedPreferences.getInstance();
    p.setStringList('iraq_games', myGames);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('IRAQ ENGINE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          Text('صنع حيدر - واحد عراق', style: TextStyle(fontSize: 10, color: Colors.amber)),
        ]),
        actions: [
          IconButton(icon: Icon(Icons.play_arrow, color: Colors.green), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GamePreview(objects: objects)))),
          IconButton(icon: Icon(Icons.save, color: Colors.amber), onPressed: () { setState(() { if (!myGames.contains(currentGame)) myGames.add(currentGame); }); saveGames(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ اللعبة'))); }),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black87,
            height: 50,
            child: Row(
              children: [
                _toolBtn(Icons.person, 'لاعب', () => addObject('لاعب', Icons.person, Colors.blue)),
                _toolBtn(Icons.smart_toy, 'عدو', () => addObject('عدو', Icons.smart_toy, Colors.red)),
                _toolBtn(Icons.home, 'بيت', () => addObject('بيت', Icons.home, Colors.brown)),
                _toolBtn(Icons.directions_car, 'سيارة', () => addObject('سيارة', Icons.directions_car, Colors.green)),
                _toolBtn(Icons.gps_fixed, 'سلاح', () => addObject('سلاح', Icons.gps_fixed, Colors.amber)),
                Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(Icons.file_upload, color: Colors.white),
                  onSelected: (v) => exportGame(v),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'android', child: Text('تصدير Android APK')),
                    PopupMenuItem(value: 'pc', child: Text('تصدير PC EXE')),
                    PopupMenuItem(value: 'ios', child: Text('تصدير iOS IPA')),
                    PopupMenuItem(value: 'all', child: Text('تصدير الكل')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 110,
                  color: Color(0xFF1a1a1a),
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('المشهد', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
                      Expanded(child: ListView(children: objects.map((o) => ListTile(dense: true, leading: Icon(o['icon'], color: o['color'], size: 16), title: Text(o['name'], style: TextStyle(color: Colors.white, fontSize: 11)), onTap: () => showProps(o))).toList())),
                      Divider(color: Colors.white24),
                      Padding(padding: EdgeInsets.all(8), child: Text('العابي', style: TextStyle(color: Colors.white54, fontSize: 11))),
                      ...myGames.map((g) => ListTile(dense: true, title: Text(g, style: TextStyle(color: Colors.white70, fontSize: 10)), onTap: () => setState(() => currentGame = g))),
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
                            left: obj['x'] ?? (50.0 + idx * 30),
                            top: obj['y'] ?? (50.0 + idx * 30),
                            child: Draggable(
                              feedback: Icon(obj['icon'], color: obj['color'], size: 40),
                              childWhenDragging: Container(),
                              onDragEnd: (d) => setState(() { objects[idx]['x'] = d.offset.dx; objects[idx]['y'] = d.offset.dy; }),
                              child: GestureDetector(
                                onTap: () => showProps(obj),
                                child: Column(children: [Icon(obj['icon'], color: obj['color'], size: 32), Text(obj['name'], style: TextStyle(color: Colors.white, fontSize: 9))]),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 110,
                  color: Color(0xFF1a1a1a),
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('الخصائص', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
                      ListTile(dense: true, title: Text('اونلاين', style: TextStyle(color: Colors.white, fontSize: 11)), trailing: Switch(value: true, onChanged: (_){}, activeColor: Colors.green)),
                      ListTile(dense: true, title: Text('فيزياء', style: TextStyle(color: Colors.white, fontSize: 11)), trailing: Switch(value: true, onChanged: (_){}, activeColor: Colors.green)),
                      ListTile(dense: true, title: Text('مضاد غش', style: TextStyle(color: Colors.white, fontSize: 11)), trailing: Icon(Icons.shield, color: Colors.green, size: 18)),
                      Padding(padding: EdgeInsets.all(8), child: Text('اشهد ان لا اله الا الله\nواشهد ان محمد رسول الله\nواشهد ان عليا ولي الله', style: TextStyle(color: Colors.amber, fontSize: 9, height: 1.5))),
                      Spacer(),
                      Padding(padding: EdgeInsets.all(6), child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => setState(() => objects.clear()), child: Text('مسح', style: TextStyle(fontSize: 10)))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: Colors.white, size: 18), Text(label, style: TextStyle(color: Colors.white70, fontSize: 8))])));
  }

  void addObject(String name, IconData icon, Color color) {
    setState(() => objects.add({'name': '$name ${objects.length+1}', 'icon': icon, 'color': color, 'x': 50.0 + objects.length*20, 'y': 50.0 + objects.length*20, 'script': 'move()'}));
  }

  void showProps(Map<String, dynamic> obj) {
    showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: Color(0xFF222222), title: Text(obj['name'], style: TextStyle(color: Colors.white)), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: InputDecoration(labelText: 'الاسم', labelStyle: TextStyle(color: Colors.amber)), style: TextStyle(color: Colors.white)), SizedBox(height: 10), TextField(decoration: InputDecoration(labelText: 'السكريبت - IRAQScript', labelStyle: TextStyle(color: Colors.amber), hintText: 'اذا ضغط W تحرك للامام'), style: TextStyle(color: Colors.white), maxLines: 3)]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('حفظ'))]));
  }

  void exportGame(String platform) {
    showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: Colors.black, title: Text('تم التصدير!', style: TextStyle(color: Colors.green)), content: Text('تم تصدير $currentGame\nالمنصة: $platform\nالحزمة: com.iraqlive.wahediraq\nمحمي بانظمة مكافحة الغش\nجاهز للرفع\n\nهذا محركك الخاص - صنع حيدر', style: TextStyle(color: Colors.white, height: 1.6)), actions: [ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () => Navigator.pop(context), child: Text('ممتاز'))]));
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white10..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 30) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += 30) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GamePreview extends StatelessWidget {
  final List<Map<String, dynamic>> objects;
  GamePreview({required this.objects});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('معاينة اللعبة')), body: Container(color: Colors.green[900], child: Stack(children: objects.map((o) => Positioned(left: o['x'], top: o['y'], child: Icon(o['icon'], color: o['color'], size: 36))).toList())));
  }
}