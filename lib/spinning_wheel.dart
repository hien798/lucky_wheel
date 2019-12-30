import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'utils.dart';

/// Returns a widget which displays a rotating image.
/// This widget can be interacted with with drag gestures and could be used as a "fortune wheel".
///
/// Required arguments are dimensions and the image to be used as the wheel.
///
///     SpinningWheel(Image.asset('assets/images/wheel-6-300.png'), width: 310, height: 310,)
///

class SpinningController {
  /// initial rotation angle from 0.0 to 2*pi
  /// default is 0.0
  double initialSpinAngle;

  /// number of equal divisions in the wheel
  final int dividers;

  // divider which is selected (positive y-coord)
  int currentDivider;

  /// has to be higher than 0.0 (no resistance) and lower or equal to 1.0
  /// default is 0.5
  final double spinResistance;

  NonUniformCircularMotion _motion;

//  NonUniformCircularMotion get motion => _motion;
  final _spinningModel = _SpinningModel();

  SpinningController({
    this.initialSpinAngle = 0.0,
    @required this.dividers,
    this.spinResistance = 0.5,
  })  : assert(spinResistance > 0.0 && spinResistance <= 1.0),
        assert(initialSpinAngle >= 0.0 && initialSpinAngle <= (2 * pi)) {
    _motion = NonUniformCircularMotion(resistance: spinResistance);
  }

  final _wheelNotifier = StreamController<_SpinningModel>();

  Stream get shouldStartOrStop => _wheelNotifier.stream;

  void run(double velocity, {bool isSteady = false}) {
    _velocity = velocity;
    _spinningModel.velocity = velocity;
    _spinningModel.isSteady = isSteady;
    _wheelNotifier.sink.add(_spinningModel);
  }

//  void run(double velocity) {
//    _velocity = velocity.abs();
//    _wheelNotifier.sink.add(velocity.abs());
//  }
//
//  void runSteady(double velocity) {
//    _wheelNotifier.sink.add(-(velocity.abs()));
//  }

  double _velocity = 0;

  int calculateResult() {
    final v0 = _velocity;
    final v = v0 / 2;
    final iCV = pixelsPerSecondToRadians(v);

    double time = _motion.duration(iCV.abs());
    var distance = _motion.distance(iCV.abs(), time);
    if (iCV < 0) {
      distance = -distance;
    }

    /// distance = (velocity * time) + (0.5 * acceleration * pow(time, 2))
    final modulo = _motion.modulo(distance + initialSpinAngle);
    // modulo = angle % m_pi;
    final dividerAngle = pi_2 / dividers;
    final divider = dividers - (modulo ~/ dividerAngle);
    print('hien ====> rs = $divider');
    return divider;
  }

  double calculateVelocity(int divider, {double maxVelocity}) {
    print('hien ====> target $divider');

    final dividerAngle = pi_2 / dividers;

    /// modulo = angle % m_pi;
    /// => angle = n * m_pi + modulo

    int n = 0;
    if (maxVelocity != null && maxVelocity < 0) {
      /// When spin backward
      final modulo = (divider) * dividerAngle -
          dividerAngle * (Random().nextInt(100) % 90 + 5) / 100;
//      n = maxVelocity.abs() < 3000.0 ? 1 : 2;
      n = maxVelocity.abs()~/1000 -1;
      final angle = n * pi_2 + modulo;
      final distance = angle + initialSpinAngle;
      /// iCV (velocity in rad):
      /// iCV = √(2aS)
      final iCV = _motion.velocityByDistance(distance);
      var velocity = 2 * radiansToPixelsPerSecond(iCV);
      return -velocity;
    } else {
      /// When spin forward
      final modulo = (dividers - divider) * dividerAngle +
          dividerAngle * (Random().nextInt(100) % 90 + 5) / 100;
      if (maxVelocity != null) {
        n = maxVelocity.abs()~/1000 -1;
      } else {
        n = Random().nextInt(100) % 5 + 5;
      }
      final angle = n * pi_2 + modulo;
      final distance = angle - initialSpinAngle;
      /// iCV (velocity in rad):
      /// iCV = √(2aS)
      final iCV = _motion.velocityByDistance(distance);
      var velocity = 2 * radiansToPixelsPerSecond(iCV);
      return velocity;
    }
  }
}

class _SpinningModel {
  double velocity;
  bool isSteady;

  _SpinningModel({this.velocity = 0.0, this.isSteady = false});
}

class SpinningWheel extends StatefulWidget {
  /// width used by the container with the image
  final double width;

  /// height used by the container with the image
  final double height;

  /// image that will be used as wheel
  final Widget backdrop;

  /// controller to get it's attribute
  final SpinningController controller;

//  /// number of equal divisions in the wheel
//  final int dividers;

  /// initial rotation angle from 0.0 to 2*pi
  /// default is 0.0
  final double initialSpinAngle;

  /// has to be higher than 0.0 (no resistance) and lower or equal to 1.0
  /// default is 0.5
  final double spinResistance;

  /// if true, the user can interact with the wheel while it spins
  /// default is true
  final bool canInteractWhileSpinning;

  /// will be rendered on top of the wheel and can be used to show a selector
  final Widget cursor;

  /// x dimension for the secondaty image, if provided
  /// if provided, has to be smaller than widget height
  final double cursorHeight;

  /// y dimension for the secondary image, if provided
  /// if provided, has to be smaller than widget width
  final double cursorWidth;

  /// can be used to fine tune the position for the secondary image, otherwise it will be centered
  final double cursorTop;

  /// can be used to fine tune the position for the secondary image, otherwise it will be centered
  final double cursorLeft;

  /// callback function to be executed when the wheel selection changes
  final Function onUpdate;

  /// callback function to be executed when the animation stops
  final Function onEnd;

  /// callback function when pan end
  final Function onPanEnd;

  /// Stream<double> used to trigger an animation
  /// if triggered in an animation it will stop it, unless canInteractWhileSpinning is false
  /// the parameter is a double for pixelsPerSecond in axis Y, which defaults to 8000.0 as a medium-high velocity
//  final Stream shouldStartOrStop;

  SpinningWheel({
    @required this.controller,
    @required this.backdrop,
    @required this.width,
    @required this.height,
    this.initialSpinAngle: 0.0,
    this.spinResistance: 0.5,
    this.canInteractWhileSpinning: true,
    this.cursor,
    this.cursorHeight,
    this.cursorWidth,
    this.cursorTop,
    this.cursorLeft,
    this.onUpdate,
    this.onEnd,
    this.onPanEnd,
  })  : assert(width > 0.0 && height > 0.0),
        assert(spinResistance > 0.0 && spinResistance <= 1.0),
        assert(initialSpinAngle >= 0.0 && initialSpinAngle <= (2 * pi)),
        assert(
            cursor == null || (cursorHeight <= height && cursorWidth <= width));

  @override
  _SpinningWheelState createState() => _SpinningWheelState();
}

class _SpinningWheelState extends State<SpinningWheel>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  // we need to store if has the widget behaves differently depending on the status
  // AnimationStatus _animationStatus = AnimationStatus.dismissed;

  // it helps calculating the velocity based on position and pixels per second velocity and angle
  SpinVelocity _spinVelocity;
  NonUniformCircularMotion _motion;

  // keeps the last local position on pan update
  // we need it onPanEnd to calculate in which cuadrant the user was when last dragged
  Offset _localPositionOnPanUpdate;

  // duration of the animation based on the initial velocity
  double _totalDuration = 0;

  // initial velocity for the wheel when the user spins the wheel
  double _initialCircularVelocity = 0;

  // angle for each divider: 2*pi / numberOfDividers
  double _dividerAngle;

  // current (circular) distance (angle) covered during the animation
  double _currentDistance = 0;

//  // initial spin angle when the wheels starts the animation
//  double widget.controller.initialSpinAngle;

  // spin angle when animation is stopped
  double _currentSpinAngle;

//  // dividider which is selected (positive y-coord)
//  int widget.controller.currentDivider;

  // spining backwards
  bool _isBackwards;

  // if the user drags outside the wheel, won't be able to get back in
  DateTime _offsetOutsideTimestamp;

  // will be used to do transformations between global and local
  RenderBox _renderBox;

  // subscription to the stream used to trigger an animation
  StreamSubscription _subscription;

  bool _isSteady = true;

  @override
  void initState() {
    super.initState();

    _spinVelocity = SpinVelocity(width: widget.width, height: widget.height);
    _motion = widget.controller._motion;

    _animationController = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 0),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));

    _dividerAngle = _motion.anglePerDivision(widget.controller.dividers);
    widget.controller.initialSpinAngle = widget.initialSpinAngle;

    _animation.addStatusListener((status) {
      // _animationStatus = status;
      if (status == AnimationStatus.completed) _stopAnimation();
    });

    if (widget.controller.shouldStartOrStop != null) {
      _subscription = widget.controller.shouldStartOrStop.listen(_startOrStop);
    }
  }

  _startOrStop(dynamic spinModel) {
    _SpinningModel model = spinModel;
    if (model == null) return;
    _isSteady = false;
    var pixelsPerSecondY = model.velocity ?? 8000.0;
    _localPositionOnPanUpdate = Offset(250.0, 250.0);
    _startAnimation(Offset(0.0, pixelsPerSecondY));
    _isSteady = model.isSteady;

//    if (_animationController.isAnimating) {
//      _stopAnimation();
//    } else {
//      // velocity is pixels per second in axis Y
//      // we asume a drag from cuadrant 1 with high velocity (8000)
//      var pixelsPerSecondY = velocity ?? 8000.0;
//      _localPositionOnPanUpdate = Offset(250.0, 250.0);
//      _startAnimation(Offset(0.0, pixelsPerSecondY));
//    }
  }

  double get topSecondaryImage =>
      widget.cursorTop ?? (widget.height / 2) - (widget.cursorHeight / 2);

  double get leftSecondaryImage =>
      widget.cursorLeft ?? (widget.width / 2) - (widget.cursorWidth / 2);

  double get widthSecondaryImage => widget.cursorWidth ?? widget.width;

  double get heightSecondaryImage => widget.cursorHeight ?? widget.height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: [
          GestureDetector(
            onPanUpdate: _moveWheel,
            onPanEnd: _startAnimationOnPanEnd,
            onPanDown: (_details) => _stopAnimation(),
            child: AnimatedBuilder(
                animation: _animation,
                child: Container(child: widget.backdrop),
                builder: (context, child) {
                  _updateAnimationValues();
                  if (widget.onUpdate != null) {
                    widget.onUpdate(widget.controller.currentDivider);
                  }
                  return Transform.rotate(
                    angle:
                        widget.controller.initialSpinAngle + _currentDistance,
                    child: child,
                  );
                }),
          ),
          widget.cursor != null
              ? Positioned(
                  top: topSecondaryImage,
                  left: leftSecondaryImage,
                  child: Container(
                    height: heightSecondaryImage,
                    width: widthSecondaryImage,
                    child: widget.cursor,
                  ))
              : Container(),
        ],
      ),
    );
  }

  // user can interact only if widget allows or wheel is not spinning
  bool get _userCanInteract =>
      !_animationController.isAnimating || widget.canInteractWhileSpinning;

  // transforms from global coordinates to local and store the value
  void _updateLocalPosition(Offset position) {
    if (_renderBox == null) {
      _renderBox = context.findRenderObject();
    }
    _localPositionOnPanUpdate = _renderBox.globalToLocal(position);
  }

  /// returns true if (x,y) is outside the boundaries from size
  bool _contains(Offset p) => Size(widget.width, widget.height).contains(p);

  // this is called just before the animation starts
  void _updateAnimationValues() {
    if (_animationController.isAnimating) {
      // calculate total distance covered
      var currentTime = _totalDuration * _animation.value;

      if (!_isSteady) {
        _currentDistance =
            _motion.distance(_initialCircularVelocity, currentTime);
      } else {
        _currentDistance =
            _motion.steady(_initialCircularVelocity, currentTime);
      }

      if (_isBackwards) {
        _currentDistance = -_currentDistance;
      }
    }
    // calculate current divider selected
    var modulo =
        _motion.modulo(_currentDistance + widget.controller.initialSpinAngle);
    widget.controller.currentDivider =
        widget.controller.dividers - (modulo ~/ _dividerAngle);
    _currentSpinAngle = modulo;
    if (_animationController.isCompleted) {
      resetSpinAngle();
    }
  }

  double _panDelta = 0;

  void _moveWheel(DragUpdateDetails details) {
    if (!_userCanInteract) return;

    // user won't be able to get back in after dragin outside
    if (_offsetOutsideTimestamp != null) return;

    _updateLocalPosition(details.globalPosition);

    if (_contains(_localPositionOnPanUpdate)) {
      // we need to update the rotation
      // so, calculate the new rotation angle and rebuild the widget
      var angle = _spinVelocity.offsetToRadians(_localPositionOnPanUpdate);
      if (_panDelta == 0) _panDelta = angle;
      angle = angle - _panDelta;
      setState(() {
        // initialSpinAngle will be added later on build
        _currentDistance = angle;
      });
    } else {
      // if user dragged outside the boundaries we save the timestamp
      // when user releases the drag, it will trigger animation only if less than duration time passed from now
      _offsetOutsideTimestamp = DateTime.now();
    }
  }

  void resetSpinAngle() {
    // save current spinAngle for next animation
    widget.controller.initialSpinAngle = _currentSpinAngle;
    _currentDistance = 0;
    _panDelta = 0;
  }

  void _stopAnimation() {
    if (!_userCanInteract) return;
    resetSpinAngle();

    _offsetOutsideTimestamp = null;
    _animationController.stop();
    _animationController.reset();

    if (widget.onEnd != null) {
      widget.onEnd(widget.controller.currentDivider);
    }
  }

  void _startAnimationOnPanEnd(DragEndDetails details) {
    if (!_userCanInteract) return;

    if (_offsetOutsideTimestamp != null) {
      var difference = DateTime.now().difference(_offsetOutsideTimestamp);
      _offsetOutsideTimestamp = null;
      // if more than 50 seconds passed since user dragged outside the boundaries, dont start animation
      if (difference.inMilliseconds > 50) return;
    }

    // it was the user just taping to stop the animation
    if (_localPositionOnPanUpdate == null) return;

    _isSteady = true;
    final localPosition = _localPositionOnPanUpdate;
    _startAnimation(details.velocity.pixelsPerSecond);
    if (widget.onPanEnd != null) {
      var velocity = _spinVelocity.getVelocity(
          localPosition, details.velocity.pixelsPerSecond);
//      final sign = velocity < 0 ? -1 : 1;
//      if (velocity.abs() < 1500.0) {
//        velocity = 1000.0*sign;
//      } else {
//        velocity = 1500.0*sign;
//      }
      widget.onPanEnd(2 * velocity);
    }
  }

  void _startAnimation(Offset pixelsPerSecond) {
    var velocity =
        _spinVelocity.getVelocity(_localPositionOnPanUpdate, pixelsPerSecond);

    _localPositionOnPanUpdate = null;
    _isBackwards = velocity < 0;
    _initialCircularVelocity = pixelsPerSecondToRadians(velocity.abs());
    if (!_isSteady) {
      _totalDuration = _motion.duration(_initialCircularVelocity);
    } else {
      _totalDuration = 30.0;
    }

    _animationController.duration =
        Duration(milliseconds: (_totalDuration * 1000).round());

    _animationController.reset();
    _animationController.forward();
  }

  dispose() {
    _animationController.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }
    super.dispose();
  }
}
