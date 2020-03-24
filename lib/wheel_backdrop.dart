import 'dart:math';

import 'package:flutter/material.dart';

class WheelBackdrop extends StatelessWidget {
  final List<String> dataSource;
  final Widget backdrop;
  final double size;

  WheelBackdrop({
    @required this.dataSource,
    @required this.backdrop,
    this.size = 300,
  }) : assert(dataSource != null && backdrop != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          backdrop,
          Stack(
            children: getListCard(),
          ),
        ],
      ),
    );
  }

  List<Widget> getListCard() {
    final List<Widget> widgets = [];

    final dividers = dataSource.length;
//    final dividers = 10;

    /// height = r * rad
    final height = (size / 2) * (2 * pi / dividers);

    for (int i = 0; i < dividers; i++) {
      final widget = Transform.rotate(
        angle: i * (2 * pi / dividers),
        child: Container(
          width: size,
          height: height,
          alignment: Alignment.centerRight,
//          color: Colors.blue,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(height: 20),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        padding: EdgeInsets.only(left: 50, right: 50),
//                        color: Colors.cyan,
                        child: Text('${dataSource[i]}', maxLines: 2,),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      widgets.add(widget);
    }

    return widgets;
  }
}

class WheelBackdropExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quay ngay'),
      ),
      body: Center(
        child: WheelBackdrop(dataSource: [], backdrop: Text('dasda')),
      ),
    );
  }
}
