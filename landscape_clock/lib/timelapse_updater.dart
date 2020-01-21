// Copyright 2020 Patrick Boos. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';

class TimeLapseUpdater extends ChangeNotifier {
  static final _dayDurationMillis = 10 * 1000; // 20 seconds
  static final _stepDurationMillis = 1000.0 ~/ 30.0; // 30 frames per second

  DateTime dateTime;
  Timer _timer;

  TimeLapseUpdater() {}

  void start() {
    _tick();
  }

  void stop() {
    _timer?.cancel();
  }

  void _tick() {
    _updateTime();
    _scheduleNextTick();
  }

  void _updateTime() {
    final dayProgress =
        (DateTime.now().millisecondsSinceEpoch % _dayDurationMillis) /
            _dayDurationMillis;

    final dayMinutes = (dayProgress * 24 * 60).round();
    final hours = (dayMinutes / 60).floor();
    final minutes = dayMinutes % 60;
    dateTime = DateTime(2020, 1, 24, hours, minutes, 0, 0, 0);
    notifyListeners();
  }

  void _scheduleNextTick() {
    _timer = Timer(
      Duration(milliseconds: _stepDurationMillis),
      _tick,
    );
  }
}
