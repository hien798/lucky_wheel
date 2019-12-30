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
                  canInteractWhileSpinning: false,
                  initialSpinAngle: 0,
                  spinResistance: 0.2,
                  onUpdate: (divider) {},
                  onEnd: (divider) {},
                  onPanEnd: (velocity) {
                    print('hien ====> velocity pan end $velocity');
                    if (velocity.abs() < 1000.0) {
                      _spinningController.run(velocity);
                      return;
                    }
                    final velo = _spinningController.calculateVelocity(7, maxVelocity: velocity);
                    Future.delayed(Duration(seconds: 3)).then((value) {

                      _spinningController.run(velo);
                      int rs = _spinningController.calculateResult();
                    });
                  },
                  cursor: Image.asset('assets/images/roulette-center-300.png'),
                  cursorWidth: 100,
                  cursorHeight: 100,
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
                      _spinningController.run(_getVelocity());
                      int rs = _spinningController.calculateResult();
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
                      final velocity = _spinningController.calculateVelocity(divider);
                      _spinningController.run(velocity);
                      _spinningController.calculateResult();
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
                      _spinningController.run(-2000);
                      _spinningController.calculateResult();
                    },
                    child: Text('Max Speed'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      _spinningController.run(6000);
                    },
                    child: Text('Run'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      _spinningController.run(6000);
                    },
                    child: Text('Next'),
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
    return _generateRandomVelocity();
  }
  
  double _generateRandomVelocity() => (Random().nextDouble() * 2000 + 2000);
}
