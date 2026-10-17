import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(IraqEmulatorApp());

class IraqEmulatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IRAQ Emulator',
      theme: ThemeData(brightness: Brightness.dark),
      home: EmulatorHome(),
    );
  }
}

class EmulatorHome extends StatefulWidget {
  @override
  _EmulatorHomeState createState() => _EmulatorHomeState();
}

class _EmulatorHomeState extends State<EmulatorHome> {
  late Chip8 chip8;
  Timer? timer;
  bool running = false;

  List<Map<String, dynamic>> roms = [
    {'name': 'PONG - بونك', 'data': PongRom},
    {'name': 'TETRIS - تتريس', 'data': TetrisRom},
    {'name': 'BRICK - طابوق', 'data': BrickRom},
  ];

  @override
  void initState() {
    super.initState();
    chip8 = Chip8();
    loadRom(roms[0]);
  }

  void loadRom(Map<String, dynamic> rom) {
    chip8.loadRom(rom['data']);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تحميل ${rom['name']}')));
  }

  void toggleRun() {
    if (running) {
      timer?.cancel();
    } else {
      timer = Timer.periodic(Duration(milliseconds: 2), (_) {
        for (int i = 0; i < 10; i++) chip8.emulateCycle();
        setState(() {});
      });
    }
    setState(() => running = !running);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('IRAQ EMULATOR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
          Text('محاكي واحد عراق - صنع حيدر', style: TextStyle(fontSize: 10, color: Colors.amber)),
        ]),
        actions: [
          IconButton(icon: Icon(running ? Icons.pause : Icons.play_arrow, color: running ? Colors.red : Colors.green, size: 30), onPressed: toggleRun),
          IconButton(icon: Icon(Icons.refresh, color: Colors.white), onPressed: () { chip8.reset(); setState(() {}); }),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF1a1a1a),
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: roms.map((r) => Padding(
                padding: EdgeInsets.all(6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2a2a2a)),
                  onPressed: () => loadRom(r),
                  child: Text(r['name'], style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 64 / 32,
                child: Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(color: Colors.amber, width: 2), color: Colors.black),
                  child: CustomPaint(painter: Chip8Painter(chip8.display), size: Size.infinite),
                ),
              ),
            ),
          ),
          Container(
            color: Color(0xFF1a1a1a),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _keyBtn('1', 0x1), _keyBtn('2', 0x2), _keyBtn('3', 0x3), _keyBtn('C', 0xC),
                ]),
                SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _keyBtn('4', 0x4), _keyBtn('5', 0x5), _keyBtn('6', 0x6), _keyBtn('D', 0xD),
                ]),
                SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _keyBtn('7', 0x7), _keyBtn('8', 0x8), _keyBtn('9', 0x9), _keyBtn('E', 0xE),
                ]),
                SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _keyBtn('A', 0xA), _keyBtn('0', 0x0), _keyBtn('B', 0xB), _keyBtn('F', 0xF),
                ]),
                SizedBox(height: 10),
                Text('PC:${chip8.pc} I:${chip8.I} | اضغط PLAY لتشغيل المحاكي', style: TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _keyBtn(String label, int key) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: chip8.keys[key] ? Colors.green : Color(0xFF333333), minimumSize: Size(60, 45)),
      onPressed: () {},
      onLongPress: () {},
      child: GestureDetector(
        onTapDown: (_) => setState(() => chip8.keys[key] = true),
        onTapUp: (_) => setState(() => chip8.keys[key] = false),
        child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class Chip8Painter extends CustomPainter {
  final List<List<int>> display;
  Chip8Painter(this.display);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.greenAccent;
    double pw = size.width / 64;
    double ph = size.height / 32;
    for (int y = 0; y < 32; y++) {
      for (int x = 0; x < 64; x++) {
        if (display[y][x] == 1) {
          canvas.drawRect(Rect.fromLTWH(x * pw, y * ph, pw, ph), paint);
        }
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Chip8 {
  List<int> memory = List.filled(4096, 0);
  List<int> V = List.filled(16, 0);
  int I = 0, pc = 0x200, sp = 0;
  List<int> stack = List.filled(16, 0);
  List<List<int>> display = List.generate(32, (_) => List.filled(64, 0));
  List<bool> keys = List.filled(16, false);
  int delayTimer = 0, soundTimer = 0;
  Random rnd = Random();

  Chip8() { reset(); }

  void reset() {
    memory = List.filled(4096, 0);
    V = List.filled(16, 0);
    I = 0; pc = 0x200; sp = 0; stack = List.filled(16, 0);
    display = List.generate(32, (_) => List.filled(64, 0));
    keys = List.filled(16, false);
    List<int> font = [0xF0,0x90,0x90,0x90,0xF0, 0x20,0x60,0x20,0x20,0x70, 0xF0,0x10,0xF0,0x80,0xF0, 0xF0,0x10,0xF0,0x10,0xF0, 0x90,0x90,0xF0,0x10,0x10, 0xF0,0x80,0xF0,0x10,0xF0, 0xF0,0x80,0xF0,0x90,0xF0, 0xF0,0x10,0x20,0x40,0x40, 0xF0,0x90,0xF0,0x90,0xF0, 0xF0,0x90,0xF0,0x10,0xF0];
    for (int i = 0; i < font.length; i++) memory[i] = font[i];
  }

  void loadRom(List<int> rom) {
    reset();
    for (int i = 0; i < rom.length; i++) memory[0x200 + i] = rom[i];
  }

  void emulateCycle() {
    int opcode = (memory[pc] << 8) | memory[pc + 1];
    pc += 2;
    int nnn = opcode & 0x0FFF;
    int n = opcode & 0x000F;
    int x = (opcode & 0x0F00) >> 8;
    int y = (opcode & 0x00F0) >> 4;
    int kk = opcode & 0x00FF;

    switch (opcode & 0xF000) {
      case 0x0000:
        if (opcode == 0x00E0) display = List.generate(32, (_) => List.filled(64, 0));
        if (opcode == 0x00EE) { sp--; pc = stack[sp]; }
        break;
      case 0x1000: pc = nnn; break;
      case 0x2000: stack[sp] = pc; sp++; pc = nnn; break;
      case 0x3000: if (V[x] == kk) pc += 2; break;
      case 0x4000: if (V[x] != kk) pc += 2; break;
      case 0x5000: if (V[x] == V[y]) pc += 2; break;
      case 0x6000: V[x] = kk; break;
      case 0x7000: V[x] = (V[x] + kk) & 0xFF; break;
      case 0x8000:
        switch (opcode & 0x000F) {
          case 0x0: V[x] = V[y]; break;
          case 0x1: V[x] |= V[y]; break;
          case 0x2: V[x] &= V[y]; break;
          case 0x3: V[x] ^= V[y]; break;
          case 0x4: int sum = V[x] + V[y]; V[0xF] = sum > 255 ? 1 : 0; V[x] = sum & 0xFF; break;
          case 0x5: V[0xF] = V[x] > V[y] ? 1 : 0; V[x] = (V[x] - V[y]) & 0xFF; break;
          case 0x6: V[0xF] = V[x] & 0x1; V[x] >>= 1; break;
          case 0x7: V[0xF] = V[y] > V[x] ? 1 : 0; V[x] = (V[y] - V[x]) & 0xFF; break;
          case 0xE: V[0xF] = (V[x] & 0x80) >> 7; V[x] = (V[x] << 1) & 0xFF; break;
        }
        break;
      case 0x9000: if (V[x] != V[y]) pc += 2; break;
      case 0xA000: I = nnn; break;
      case 0xB000: pc = nnn + V[0]; break;
      case 0xC000: V[x] = rnd.nextInt(256) & kk; break;
      case 0xD000:
        V[0xF] = 0;
        for (int row = 0; row < n; row++) {
          int sprite = memory[I + row];
          for (int col = 0; col < 8; col++) {
            if ((sprite & (0x80 >> col)) != 0) {
              int px = (V[x] + col) % 64;
              int py = (V[y] + row) % 32;
              if (display[py][px] == 1) V[0xF] = 1;
              display[py][px] ^= 1;
            }
          }
        }
        break;
      case 0xE000:
        if ((opcode & 0x00FF) == 0x9E) { if (keys[V[x]]) pc += 2; }
        if ((opcode & 0x00FF) == 0xA1) { if (!keys[V[x]]) pc += 2; }
        break;
      case 0xF000:
        switch (opcode & 0x00FF) {
          case 0x07: V[x] = delayTimer; break;
          case 0x0A:
            bool pressed = false;
            for (int i = 0; i < 16; i++) if (keys[i]) { V[x] = i; pressed = true; }
            if (!pressed) pc -= 2;
            break;
          case 0x15: delayTimer = V[x]; break;
          case 0x18: soundTimer = V[x]; break;
          case 0x1E: I = (I + V[x]) & 0xFFF; break;
          case 0x29: I = V[x] * 5; break;
          case 0x33: memory[I] = V[x] ~/ 100; memory[I+1] = (V[x] ~/ 10) % 10; memory[I+2] = V[x] % 10; break;
          case 0x55: for (int i = 0; i <= x; i++) memory[I+i] = V[i]; break;
          case 0x65: for (int i = 0; i <= x; i++) V[i] = memory[I+i]; break;
        }
        break;
    }
    if (delayTimer > 0) delayTimer--;
    if (soundTimer > 0) soundTimer--;
  }
}

// رومات جاهزة
const List<int> PongRom = [0x60,0x00,0x61,0x00,0x62,0x00,0x63,0x00,0x64,0x00,0x65,0x00,0xA2,0x20,0xC2,0x30,0x32,0x28,0xA2,0x40,0xC2,0x0F,0x32,0x30,0xA2,0x50,0xC2,0x07,0x32,0x30,0x60,0x00,0x61,0x0F,0xA2,0x10,0xD0,0x11,0x70,0x08,0x30,0x40,0x12,0x08,0x60,0x00,0x71,0x01,0x31,0x20,0x12,0x06,0x00,0xEE];
const List<int> TetrisRom = [0x60,0x00,0x61,0x00,0xA2,0x20,0xC2,0x0A,0x32,0x08,0xA2,0x30,0xD0,0x11,0x60,0x0A,0x70,0x08,0x30,0x40,0x12,0x00,0x00,0xEE];
const List<int> BrickRom = [0x60,0x00,0x61,0x00,0xA2,0x10,0xD0,0x11,0x60,0x04,0x61,0x02,0xD0,0x11,0x12,0x06,0x00,0xEE];