import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucky_wheel/spinning_wheel.dart';
import 'package:lucky_wheel/wheel_backdrop.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (ctx) => HomePage()));
              },
              child: Text('Quay'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => WheelBackdropExample()));
              },
              child: Text('Backdrop'),
            ),
          ],
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _wheelNotifier = StreamController<double>();
  final StreamController _dividerController = StreamController<int>();

  double spinAngle = pi / 2;
  TextEditingController _textEditingController;
  SpinningController _spinningController;
  final _dataSource = [
    '1Tr',
    '200k',
    '100k',
    '500k',
    '1Tr5',
    'GOOD LUCK',
    '300k',
    '1đ'
  ];
  String _dropdownValue = 'None';
  String result = '';

  @override
  void initState() {
    super.initState();
    if (_dataSource.length > 0) {
      _dropdownValue = _dataSource.first;
    }
    _textEditingController = TextEditingController(text: '4');
    _spinningController = SpinningController(
        dividers: _dataSource.length,
        initialSpinAngle: 0,
        spinResistance: 0.125);
  }

  @override
  void dispose() {
    _dividerController.close();
    _wheelNotifier.close();
    super.dispose();
  }

  DateTime time = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Lucky Wheel'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.blue,
                alignment: Alignment.center,
                child: SpinningWheel(
                  controller: _spinningController,
//                  backdrop: Image.asset('assets/images/wheel.png'),
                  backdrop: WheelBackdrop(
                    dataSource: _dataSource,
                    backdrop:
                        Image.asset('assets/images/backdrop_empty_index.png'),
                  ),
//                  cursorLeft: 200,
//                  cursorTop: 200,
                  width: 300,
                  height: 300,
                  canInteractWhileSpinning: false,
                  onUpdate: (divider) {},
                  onEnd: (divider) {
                    DateTime now = DateTime.now();
                    print(
                        'hien ===> delta: ${now.difference(time)}, at $divider');
                  },
                  onPanEnd: (velocity) {
                    print('hien ====> velocity pan end $velocity');
                    if (velocity.abs() < 3000.0) {
                      _spinningController.run(velocity);
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text('Quay mạnh lên bạn '),
                        duration: Duration(milliseconds: 500),
                      ));
                      return;
                    }
                    final velo = _spinningController.calculateVelocity(
                        Random().nextInt(8),
                        maxVelocity: velocity);
                    Future.delayed(Duration(seconds: 3)).then((value) {
                      _spinningController.run(velo);
                      int rs = _spinningController.calculateResult();
                      setState(() {
                        result = '$rs';
                      });
                    });
                  },
                  cursor: Image.asset('assets/images/cursor_right.png'),
                  cursorWidth: 100,
                  cursorHeight: 100,
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Kết quả: $result'),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
//                      _spinningController.run(_getVelocity());
                              _spinningController.run(3500 +
                                  (DateTime.now().millisecondsSinceEpoch % 3500)
                                      .toDouble());

                              /// TODO Range velocity from 3500 -> 4500 with resistance 0.125 is really coming real
                              time = DateTime.now();
                              int rs = _spinningController.calculateResult();
                              setState(() {
                                result = '$rs';
                              });
                            },
                            child: Text('Random'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DropdownButton<String>(
                            value: _dropdownValue,
                            icon: Icon(Icons.arrow_drop_down),
                            onChanged: (newValue) {
                              setState(() {
                                _dropdownValue = newValue;
                              });
                            },
                            items: _dataSource
                                .map((value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ))
                                .toList(),
                          ),
//                          Container(
//                            width: 100,
//                            child: TextField(
//                              controller: _textEditingController,
//                              maxLines: 1,
//                              keyboardType: TextInputType.number,
//                            ),
//                          ),
                          RaisedButton(
                            onPressed: () {
                              var divider = _dataSource.indexOf(_dropdownValue);
                              if (divider < 0) {
                                return;
                              }

//                              int divider = int.tryParse(
//                                      _textEditingController.value.text) ??
//                                  5;
//                              divider =
//                                  divider > 0 && divider <= 10 ? divider : 1;
//                              _textEditingController.text = '$divider';
                              final velocity = _spinningController
                                  .calculateVelocity(divider);
                              _spinningController.run(velocity, isSteady: true);
                              time = DateTime.now();
                              Future.delayed(Duration(seconds: 1))
                                  .then((value) {
                                _spinningController.run(velocity);
                                _spinningController.calculateResult();
                              });
                            },
                            child: Text('Cheat'),
                          ),
                        ],
                      ),
                    ),
//                    Expanded(
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          RaisedButton(
//                            onPressed: () {
//                              _spinningController.run(-3000);
//                              _spinningController.calculateResult();
//                            },
//                            child: Text('Max Speed'),
//                          ),
//                        ],
//                      ),
//                    ),
//                    Expanded(
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          RaisedButton(
//                            onPressed: () {
//                              _spinningController.run(6000);
//                            },
//                            child: Text('Run'),
//                          ),
//                          RaisedButton(
//                            onPressed: () {
//                              _spinningController.run(6000);
//                            },
//                            child: Text('Next'),
//                          ),
//                        ],
//                      ),
//                    ),
                  ],
                ),
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
