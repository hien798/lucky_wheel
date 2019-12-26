import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucky_wheel/spinning_wheel.dart';

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

  @override
  void dispose() {
    _dividerController.close();
    _wheelNotifier.close();
    super.dispose();
  }

  double spinAngle = pi / 2;
  TextEditingController _textEditingController =
      TextEditingController(text: '0');

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
                  Image.asset('assets/images/wheel.png'),
                  width: 300,
                  height: 300,
                  dividers: 10,
                  initialSpinAngle: 0,
                  spinResistance: 0.2,
                  onUpdate: (divider) {
//                    print('hien ====> onUpdate');
//                    _dividerController.add();
                  },
                  onEnd: (divider) {
                    print('hien ====> onEnd $divider');
//                    setState(() {
//                      spinAngle = (divider / 8) * 2 * pi;
//                    });
//                    _dividerController.add;
                  },
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
                      _wheelNotifier.sink.add(_getVelocity());
                    },
                    child: Text('Start'),
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
    print('hien ====> target: $target');
    return target*6000.0;
//    return _generateRandomVelocity();
  }

  double _generateRandomVelocity() => (Random().nextDouble() * 1000) + 1000;
}
