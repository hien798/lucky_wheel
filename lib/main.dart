import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucky_wheel/spinning_wheel.dart';
import 'package:lucky_wheel/utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (ctx) => HomePage()));
          },
          child: Text('Quay'),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _wheelNotifier = StreamController<double>();
  final StreamController _dividerController = StreamController<int>();

  double spinAngle = pi / 2;
  TextEditingController _textEditingController;
  SpinningController _spinningController;
  final dividers = 10;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: '7');
    _spinningController = SpinningController(
        dividers: dividers, initialSpinAngle: 0, spinResistance: 0.2);
  }

  @override
  void dispose() {
    _dividerController.close();
    _wheelNotifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lucky Wheel'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Colors.blue,
                child: SpinningWheel(
                  controller: _spinningController,
                  backdrop: Image.asset('assets/images/wheel.png'),
                  width: 300,
                  height: 300,
                  initialSpinAngle: 0,
                  spinResistance: 0.2,
                  onUpdate: (divider) {},
                  onEnd: (divider) {},
                  cursor: Image.asset('assets/images/roulette-center-300.png'),
                  cursorWidth: 100,
                  cursorHeight: 100,
                  shouldStartOrStop: _wheelNotifier.stream,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      _wheelNotifier.sink.add(_getVelocity());
                      _calculateResult();
                    },
                    child: Text('Start'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 100,
                    child: TextField(
                      controller: _textEditingController,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      int divider =
                          int.tryParse(_textEditingController.value.text) ?? 5;
                      divider = divider > 0 && divider <= 10 ? divider : 1;
                      _textEditingController.text = '$divider';
                      print('hien ====> Target $divider');
                      final velocity = _calculateVelocity(divider);
                      _wheelNotifier.add(0);
                      _wheelNotifier.add(velocity);
                    },
                    child: Text('Cheat'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      _wheelNotifier.sink.add(1000000);
                    },
                    child: Text('Max Speed'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getVelocity() {
    int target = int.tryParse(_textEditingController.value.text) ?? 1;
    if (target < 1 || target > 10) target = 1;
    _velocity = _generateRandomVelocity();
    return _velocity;
  }

  double _velocity = 0;

  int _calculateResult() {
    final motion = NonUniformCircularMotion(
        resistance: _spinningController.spinResistance);
    final v0 = _velocity;
    final v = v0 / 2;
    final iCV = pixelsPerSecondToRadians(v.abs());

    double time = motion.duration(iCV);
    final distance = motion.distance(iCV, time);

    /// distance = (velocity * time) + (0.5 * acceleration * pow(time, 2))
    final modulo =
        motion.modulo(distance + _spinningController.initialSpinAngle);
    // modulo = angle % m_pi;
    final dividerAngle = pi_2 / _spinningController.dividers;
    final divider = _spinningController.dividers - (modulo ~/ dividerAngle);
    print('hien ====> rs = $divider');
    return 0;
  }

  double _calculateVelocity(int divider) {
    final motion = NonUniformCircularMotion(
        resistance: _spinningController.spinResistance);
    final dividerAngle = pi_2 / _spinningController.dividers;
    final modulo = (_spinningController.dividers - divider) * dividerAngle +
        dividerAngle * (Random().nextInt(100) % 90 + 5) / 100;

    /// modulo = angle % m_pi;
    /// => angle = n * m_pi + modulo
    final angle = (Random().nextInt(100) % 5 + 5) * pi_2 + modulo;
    final distance = angle - _spinningController.initialSpinAngle;
    final iCV = motion.velocityByDistance(distance);
    final velocity = 2 * radiansToPixelsPerSecond(iCV);
    return velocity;
  }

  double _generateRandomVelocity() => (Random().nextDouble() * 2000 + 2000);
}
