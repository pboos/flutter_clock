// Copyright 2020 Patrick Boos. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class DayPositions {
  static final totalDayMinutes = 24 * 60;
  static final sunrise = const TimeOfDay(hour: 6, minute: 0);
  static final sunset = const TimeOfDay(hour: 19, minute: 0);

  static final darkenFromPositionPercentage = 0.7;
  static final maxDarkenPercentage = 0.9;

  DateTime dateTime;
  TimeOfDay timeOfDay;

  double sunPosition;
  double moonPosition;

  bool get isDaylight =>
      _isBefore(sunrise, timeOfDay) && _isBefore(timeOfDay, sunset);

  bool get isNight => !isDaylight;

  DayPositions(this.dateTime) {
    timeOfDay = TimeOfDay.fromDateTime(dateTime);
    final sunriseMinutes = getDayMinutes(sunrise);
    final sunsetMinutes = getDayMinutes(sunset);
    final dayMinutes = getDayMinutes(timeOfDay);

    final sunDuration = sunsetMinutes - sunriseMinutes;
    sunPosition = isDaylight
        ? (dayMinutes - sunriseMinutes).toDouble() / sunDuration
        : _isBefore(timeOfDay, sunrise) ? 0.0 : 1.0;

    final moonDuration = totalDayMinutes - sunDuration;
    moonPosition = isNight
        ? (_isBefore(sunset, timeOfDay)
                    ? dayMinutes - sunsetMinutes
                    : totalDayMinutes - sunsetMinutes + dayMinutes)
                .toDouble() /
            moonDuration
        // TODO _isBefore(sunset, timeOfDay) is not correct, needs to be switching between middle of sunset and sunrise
        : _isBefore(sunset, timeOfDay) ? 0.0 : 1.0;
  }

  int getDayMinutes(TimeOfDay timeOfDay) =>
      timeOfDay.hour * 60 + timeOfDay.minute;

  double getSkyDarkeningPercentage() {
    if (isNight) return maxDarkenPercentage;

    final startEndDistance = (0.5 - (sunPosition - 0.5).abs()) * 2;
    final centerDistance = 1 - startEndDistance;

    if (centerDistance > darkenFromPositionPercentage) {
      final darkenPercentage = (centerDistance - darkenFromPositionPercentage) *
          (1 / (1 - darkenFromPositionPercentage));

      return darkenPercentage > maxDarkenPercentage
          ? maxDarkenPercentage
          : darkenPercentage;
    } else {
      return 0.0;
    }
  }

  double getLandscapeDarkeningPercentage() {
    return getSkyDarkeningPercentage() * 0.7;
  }
}

double _toDouble(TimeOfDay time) => time.hour + time.minute / 60.0;

bool _isBefore(TimeOfDay time1, TimeOfDay time2) {
  double _timeDiff = _toDouble(time1) - _toDouble(time2);
  return _timeDiff < 0;
}
