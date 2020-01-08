// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as Math;

import 'package:digital_clock/fake_time_updater.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tinycolor/tinycolor.dart';

import 'model/DayPositions.dart';
import 'model/Landscape.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _landscape = Landscape1;

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class LandscapeClock extends StatefulWidget {
  const LandscapeClock(this.model);

  final ClockModel model;

  @override
  _LandscapeClockState createState() => _LandscapeClockState();
}

class _LandscapeClockState extends State<LandscapeClock>
    with SingleTickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  DayPositions _dayPositions;
  Timer _timer;

  FakeTimeUpdater _timeUpdater;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);

    // TODO for publish, use _updateTime!
    //      as well remove SingleTickerProviderStateMixin
    // _updateTime();
    _timeUpdater = FakeTimeUpdater(vsync: this);
    _timeUpdater.addListener(_updateTime);
    _timeUpdater.start();

    _updateModel();
  }

  @override
  void didUpdateWidget(LandscapeClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timeUpdater.dispose();
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = _timeUpdater.dateTime; // DateTime.now();
      _dayPositions = DayPositions(_dateTime);
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
    DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 4;
    final defaultStyle = GoogleFonts.skranji(
      textStyle: TextStyle(
        color: colors[_Element.text],
      ),
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
    );

    return DefaultTextStyle(
      style: defaultStyle,
      child: Stack(children: <Widget>[
        Positioned.fill(
          child: Image(
            image: AssetImage('assets/landscape1/landscape1_background.png'),
            fit: BoxFit.cover,
            color: Colors.grey,
            colorBlendMode: BlendMode.modulate,
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: SunPainter(_landscape, _dayPositions),
          ),
        ),
        Positioned.fill(
          child: Image(
            image: AssetImage('assets/${_landscape.landscape}'),
            fit: BoxFit.cover,
            color: Colors.grey,
            colorBlendMode: BlendMode.modulate,
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.5,
            // TODO: Maybe this depends on the landscape and adjust according to time?
            child: Center(
              child: Text(
                "$hour:$minute",
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.9,
            child: Center(
              child: Text(
                "$hour:$minute",
                style: defaultStyle.copyWith(
                    foreground: Paint()
                      ..color = colors[_Element.shadow]
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}


class SunPainter extends CustomPainter {
  Landscape landscape;
  DayPositions dayPositions;

  SunPainter(this.landscape, this.dayPositions);

  @override
  void paint(Canvas canvas, Size size) {
//    final rect = Rect.fromCircle(center: size.center(Offset(0, 0)), radius: 30.0);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final radius = 0.15;
    final darkenFromPositionPercentage = 0.05;
    final positionPercent = Curves.easeInOut
        .transform(dayPositions.sunPosition); // 0.0 - 1.0 (0 = left, 1 = right)

    final sunSize = Math.min(size.width, size.height) * (radius * 2);
    final sunPercentageHorizontal = sunSize / size.width;
    final sunPercentageVertical = sunSize / size.height;

    final horizontalPosition = rangePosition(sunPercentageHorizontal - 1,
        1 - sunPercentageHorizontal, positionPercent);

    final horizonPosition = -(2 * landscape.horizon - 1.0);
    final verticalPosition = rangePosition(
        sunPercentageVertical - 1,
        horizonPosition + sunPercentageVertical,
        ((Curves.slowMiddle.transform(positionPercent) - 0.5).abs() * 2));

    final startEndDistance = 0.5 - (positionPercent - 0.5).abs();
    final darkenPercentage = darkenFromPositionPercentage > 0 &&
        startEndDistance < darkenFromPositionPercentage
        ? Curves.easeIn
        .transform(1 - startEndDistance / darkenFromPositionPercentage)
        : 0.0;

    final colorSky = darkenPercentage != 0
        ? TinyColor(landscape.colorSkyDay)
        .darken((darkenPercentage * 100).round())
        .color
        : landscape.colorSkyDay;

    const colorSun = const Color(0xFFFFFF00);
    var gradient = RadialGradient(
      center: Alignment(horizontalPosition, verticalPosition),
      radius: 1,
      colors: [
        colorSun, // yellow sun
        Color.lerp(colorSun, Colors.transparent, 0.7),
        Colors.transparent, // blue sky
        Colors.transparent, // blue sky
      ],
      stops: [0.4 * radius, radius, /* sun on left */ 3 * radius, 1.0],
    );
    // rect is the area we are painting over
    var paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

//    canvas.drawLine(
//        Offset(0.0, size.height - size.height * landscape.horizon),
//        Offset(size.width, size.height - size.height * landscape.horizon),
//        Paint()..color = Colors.black);
//    canvas.drawLine(
//        Offset(0.0, size.height * radius * 2),
//        Offset(size.width, size.height * radius * 2),
//        Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO this should depend on time, if it changed position or so..
    return false;
  }

  double rangePosition(double start, double end, double percent) {
    final rangeWidth = end - start;
    return rangeWidth * percent + start;
  }
}
