import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _wheelNotifier = StreamController<double>();
  final StreamController _dividerController = StreamController<int>();

  double _spinAngle = pi / 2;
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
  String _result = '';

  TabController _tabController;
  ScrollController _scrollController;

  final _kTabBarHeight = 44.0;

  @override
  void initState() {
    super.initState();
    if (_dataSource.length > 0) {
      _dropdownValue = _dataSource.first;
    }
    _scrollController = ScrollController();
    _tabController = TabController(vsync: this, length: 2);
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
  bool _isDrag = false;

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final height = query.size.height -
        query.padding.top -
        query.padding.bottom -
        kToolbarHeight - _kTabBarHeight - 4.0;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Lucky Wheel'),
      ),
      backgroundColor: Colors.redAccent,
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollState) {
            if (scrollState is ScrollStartNotification &&
                scrollState.metrics.axis == Axis.vertical &&
                scrollState.depth == 0 && _scrollController.offset < height) {
              if (scrollState.dragDetails != null) {
                _isDrag = true;
              }
            }
            if (scrollState is ScrollEndNotification &&
                scrollState.metrics.axis == Axis.vertical &&
                scrollState.depth == 0 && _isDrag && _scrollController.offset < height) {
              _isDrag = false;
              print('HIEN ===> axisDirection ${_scrollController.position.userScrollDirection}');
              if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
                Future.delayed(Duration(microseconds: 0)).then((s) {
                  _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.linear);
                });
              }
              if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
                Future.delayed(Duration(microseconds: 0)).then((s) {
                  _scrollController.animateTo(height, duration: Duration(milliseconds: 300), curve: Curves.linear);
                });
              }
            }

//            if (scrollState is ScrollEndNotification &&
//                scrollState.metrics.axis == Axis.vertical &&
//                _scrollController.offset < height &&
//                scrollState.depth == 0 &&
//                _isDrag) {
//              _isDrag = false;
//              print('HIEN ===> scroll end');
//              if (scrollState.metrics.axisDirection == AxisDirection.down) {
//                print('HIEN ===> AxisDirection.down');
//                Future.delayed(Duration(milliseconds: 500)).then((s) {
//                  _scrollController.animateTo(height,
//                      duration: Duration(seconds: 1),
//                      curve: Curves.linearToEaseOut);
//                });
//              } else if (scrollState.metrics.axisDirection ==
//                  AxisDirection.up) {
//                print('HIEN ===> AxisDirection.up');
//                Future.delayed(Duration(milliseconds: 500)).then((s) {
//                  _scrollController.animateTo(0,
//                      duration: Duration(seconds: 1),
//                      curve: Curves.linearToEaseOut);
//                });
//              }
//            }
            return false;
          },
          child: NestedScrollView(
            controller: _scrollController,
//          physics: NeverScrollableScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    height: height,
                    color: Colors.red,
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
                              backdrop: Image.asset(
                                  'assets/images/backdrop_empty_index.png'),
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
                              final velo = _spinningController
                                  .calculateVelocity(Random().nextInt(8),
                                      maxVelocity: velocity);
                              Future.delayed(Duration(seconds: 3))
                                  .then((value) {
                                _spinningController.run(velo);
                                int rs = _spinningController.calculateResult();
                                setState(() {
                                  _result = '$rs';
                                });
                              });
                            },
                            cursor:
                                Image.asset('assets/images/cursor_right.png'),
                            cursorWidth: 100,
                            cursorHeight: 100,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text('Kết quả: $_result'),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    RaisedButton(
                                      onPressed: () {
//                      _spinningController.run(_getVelocity());
                                        _spinningController.run(3500 +
                                            (DateTime.now()
                                                        .millisecondsSinceEpoch %
                                                    3500)
                                                .toDouble());

                                        /// TODO Range velocity from 3500 -> 4500 with resistance 0.125 is really coming real
                                        time = DateTime.now();
                                        int rs = _spinningController
                                            .calculateResult();
                                        setState(() {
                                          _result = '$rs';
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
                                          .map((value) =>
                                              DropdownMenuItem<String>(
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
                                        var divider =
                                            _dataSource.indexOf(_dropdownValue);
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
                                        _spinningController.run(velocity,
                                            isSteady: true);
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: <Widget>[
                PreferredSize(
                  preferredSize: Size.fromHeight(_kTabBarHeight),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.yellow,
                    labelColor: Colors.yellow,
                    unselectedLabelColor: Colors.white,
                    onTap: (index) {
                      _scrollController.animateTo(height,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.linearToEaseOut);
                    },
                    tabs: <Widget>[
                      Tab(
                        child: Text('Đang bán'),
                      ),
                      Tab(
                        child: Text('Sắp bán'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      ListView.builder(
                        itemCount: 20,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 100,
                            child: Text('Chapter $index'),
                          );
                        },
                      ),
                      Container(
                        height: 900,
                        child: Text('Tab 22222'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToGamePlay() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.linearToEaseOut);
  }

  double _getVelocity() {
    int target = int.tryParse(_textEditingController.value.text) ?? 1;
    if (target < 1 || target > 10) target = 1;
    return _generateRandomVelocity();
  }

  double _generateRandomVelocity() => (Random().nextDouble() * 2000 + 2000);
}
