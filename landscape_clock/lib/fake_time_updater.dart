import 'dart:async';

import 'package:flutter/widgets.dart';

class FakeTimeUpdater extends ChangeNotifier {
  final AnimationController _controller;

  DateTime dateTime;
  Timer _timer;

  FakeTimeUpdater({@required TickerProvider vsync})
      : _controller =
            AnimationController(vsync: vsync, duration: Duration(seconds: 20)) {
    //    _controller.addStatusListener((status) {
    //      if (status == AnimationStatus.completed)
    //        _controller.forward();
    //      else if (status == AnimationStatus.dismissed) _controller.forward();
    //    });

    _controller.addListener(() => _updateFakeTime());

    //    _controller.forward();
    _controller.repeat();

    _updateFakeTime();
  }

  void start() {
    _controller.repeat();
  }

  void stop() {
    _controller.stop();
    _controller.dispose();
    _timer?.cancel();
  }

  void _updateFakeTime() {
    final dayMinutes = (_controller.value * 24 * 60).round();
    final hours = (dayMinutes / 60).floor();
    final minutes = dayMinutes % 60;
    dateTime = DateTime(2020, 1, 24, hours, minutes, 0, 0, 0);
    notifyListeners();

    // Update once per minute. If you want to update every second, use the
    // following code.
    _timer = Timer(
      Duration(minutes: 1) -
          Duration(seconds: dateTime.second) -
          Duration(milliseconds: dateTime.millisecond),
      _updateFakeTime,
    );
    // Update once per second, but make sure to do it at the beginning of each
    // new second, so that the clock is accurate.
    // _timer = Timer(
    //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
    //   _updateTime,
    // );
  }
}
