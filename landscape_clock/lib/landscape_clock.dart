// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as Math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:landscape_clock/timelapse_updater.dart';

import 'model/DayPositions.dart';
import 'model/Landscape.dart';
import 'model/Star.dart';
import 'model/WeatherLayer.dart';

enum _Element {
  text,
  shadow,
}

const enableTimeLapse = false;
final _landscape = Landscape1;

final _lightTheme = {
  _Element.text: Colors.white54,
  _Element.shadow: Colors.black87,
};

final _darkTheme = {
  _Element.text: Colors.black45,
  _Element.shadow: Colors.white70,
};

class LandscapeClock extends StatefulWidget {
  const LandscapeClock(this.model);

  final ClockModel model;

  @override
  _LandscapeClockState createState() => _LandscapeClockState();
}

class _LandscapeClockState extends State<LandscapeClock> {
  BoxConstraints _constraints;

  DateTime _dateTime = DateTime.now();
  DayPositions _dayPositions;
  SunMoonPath _sunMoonPath = SunMoonPath();
  List<Star> _stars = List();
  Timer _timer;

  TimeLapseUpdater _timeUpdater;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);

    // TODO for publish, use _updateTime!
    //      as well remove SingleTickerProviderStateMixin
    if (enableTimeLapse) {
      _timeUpdater = TimeLapseUpdater();
      _timeUpdater.addListener(_updateTime);
      _timeUpdater.start();
    } else {
      _updateTime();
    }

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
      if (enableTimeLapse) {
        _dateTime = _timeUpdater.dateTime; // DateTime.now();
      } else {
        _dateTime = DateTime.now();
//        _dateTime = DateTime(2020, 1, 1, 4, 10, 0, 0, 0);
      }
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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (_constraints == null ||
          _constraints.maxWidth != constraints.maxWidth ||
          _constraints.maxHeight != constraints.maxHeight) {
        _constraints = constraints;
        _updateStars(constraints);
        _sunMoonPath.update(constraints);
      }

      final weatherLayer =
          getWeatherLayerForCondition(widget.model.weatherCondition);

      return Stack(children: <Widget>[
        _buildSkyBackground(),
        _buildStars(constraints),
        _buildSunMoon(constraints),
        if (weatherLayer.position == WeatherLayerPosition.behindLandscape)
          _buildWeather(weatherLayer),
        _buildLandscape(),
        if (weatherLayer.position == WeatherLayerPosition.aboveLandscape)
          _buildWeather(weatherLayer),
        _buildTime(),
        _buildBottomBar(),
      ]);
    });
  }

  Positioned _buildSkyBackground() {
    final darkeningPercentage = _dayPositions.getSkyDarkeningPercentage();
    return Positioned.fill(
      child: Image(
        image: AssetImage('assets/${_landscape.background}'),
        fit: BoxFit.cover,
        color: _getDarkenModulateColor(darkeningPercentage),
        colorBlendMode: BlendMode.modulate,
      ),
    );
  }

  Widget _buildStars(BoxConstraints constraints) {
    if (_dayPositions.getSkyDarkeningPercentage() == 0) return Container();

    final rotation =
        (_dateTime.hour * 60 + _dateTime.minute) / (24 * 60) * Math.pi * 2;

    return Positioned.fill(
      child: Opacity(
        opacity: _dayPositions.getSkyDarkeningPercentage(),
        child: CustomPaint(
          painter: StarsPainter(_stars, rotation),
        ),
      ),
    );
  }

  Positioned _buildSunMoon(BoxConstraints constraints) {
    final showSun = _dayPositions.isDaylight;
    final sunMoonOffset = showSun
        ? _sunMoonPath.getProgressOffset(_dayPositions.sunPosition)
        : _sunMoonPath.getProgressOffset(_dayPositions.moonPosition);

    // TODO first and last few percent (maybe like 2-3) fade the sun alpha

    return Positioned(
      child: Image.asset(
        showSun ? "assets/sun.png" : "assets/moon.png",
        height: _sunMoonPath.sunMoonSize,
      ),
      left: sunMoonOffset.dx,
      top: sunMoonOffset.dy,
    );
  }

  Positioned _buildLandscape() {
    final darkeningPercentage = _dayPositions.getLandscapeDarkeningPercentage();
    return Positioned.fill(
      child: Image(
        image: AssetImage('assets/${_landscape.landscape}'),
        fit: BoxFit.cover,
        color: _getDarkenModulateColor(darkeningPercentage),
        colorBlendMode: BlendMode.modulate,
      ),
    );
  }

  Widget _buildWeather(WeatherLayer weatherLayer) {
    final darkeningPercentage = _dayPositions.getLandscapeDarkeningPercentage();
    return Positioned.fill(
      child: Image(
        image: AssetImage('assets/${weatherLayer.asset}'),
        fit: BoxFit.cover,
        color: _getDarkenModulateColor(darkeningPercentage),
        colorBlendMode: BlendMode.modulate,
      ),
    );
  }

  Widget _buildTime() {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 4;

//    final defaultStyle = GoogleFonts.skranji( // nice looking but positions jump
//    final defaultStyle = GoogleFonts.robotoCondensed( // positions = ok, but not so ncie
//    final defaultStyle = GoogleFonts.titilliumWeb( // positions = ok, but not so ncie
//    final defaultStyle = GoogleFonts.changaOne(
//      textStyle: TextStyle(
//        color: colors[_Element.text],
//      ),
////      fontWeight: FontWeight.bold,
//      fontSize: fontSize,
//    );

    return Positioned.fill(
      child: Center(child: _buildText("$hour:$minute", fontSize)),
    );
  }

  Widget _buildBottomBar() {
    final padding = 8.0;
    final fontSize = 20.0;
    return Positioned(
      left: padding,
      right: padding,
      bottom: padding,
      height: fontSize,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _buildText(widget.model.location, fontSize),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildText(widget.model.temperatureString, fontSize),
            ),
          ),
        ],
      ),
    );
  }

  DefaultTextStyle _buildText(String text, double fontSize) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: "ChangaOne-Regular",
        fontSize: fontSize,
        color: colors[_Element.text],
      ),
      child: Stack(
        children: <Widget>[
          Text(text),
          Text(
            text,
            style: TextStyle(
                foreground: Paint()
                  ..color = colors[_Element.shadow]
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1),
          ),
        ],
      ),
    );
  }

  void _updateStars(BoxConstraints constraints) {
    _stars.clear();

    // size = diagonal because we rotate the stars
    final size = Math.sqrt(
      Math.pow(Math.max(constraints.maxWidth, constraints.maxHeight), 2) +
          Math.pow(Math.min(constraints.maxWidth, constraints.maxHeight), 2),
    );

    final random = Math.Random();
    for (int i = 0; i < 200; i++) {
      _stars.add(Star(
        position: Offset(
          random.nextDouble() * size,
          random.nextDouble() * size,
        ),
        size: random.nextDouble() * 2,
        brightness: random.nextDouble(),
      ));
    }
  }

  Color _getDarkenModulateColor(double darkeningPercentage) =>
      Color.lerp(Colors.white, Colors.black, darkeningPercentage);
}

class SunMoonPath {
  BoxConstraints _constraints;
  PathMetric _pathMetrics;
  double _sunMoonSize;

  double get sunMoonSize => _sunMoonSize;

  void update(BoxConstraints constraints) {
    if (_constraints == null ||
        _constraints.maxWidth != constraints.maxWidth ||
        _constraints.maxHeight != constraints.maxHeight) {
      _constraints = constraints;

      _sunMoonSize =
          Math.min(constraints.maxWidth, constraints.maxHeight) * 0.75;

      final horizonHeight =
          constraints.maxHeight - constraints.maxHeight * _landscape.horizon;

      final path = Path();
      path.moveTo(0, horizonHeight);
      path.quadraticBezierTo(constraints.maxWidth / 2, -horizonHeight,
          constraints.maxWidth, horizonHeight);

      _pathMetrics = path.computeMetrics().first;
    }
  }

  Offset getProgressOffset(double progress) {
    return _pathMetrics
        .getTangentForOffset(progress * _pathMetrics.length)
        .position
        .translate(-_sunMoonSize / 2, -_sunMoonSize / 3);
  }
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double rotation;

  StarsPainter(this.stars, this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    stars.forEach((star) => canvas.drawCircle(
          rotate(
              star.position, Offset(size.width / 2, size.height / 2), rotation),
          star.size,
          paint
            ..color = Color.lerp(
              Colors.transparent,
              Colors.white,
              star.brightness,
            ),
        ));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  Offset rotate(Offset position, Offset origin, double rotationRadians) {
    final cos = Math.cos(rotationRadians);
    final sin = Math.sin(rotationRadians);

    final positionTranslated = position.translate(-origin.dx, -origin.dy);

    return Offset(
      positionTranslated.dx * cos - positionTranslated.dy * sin + origin.dx,
      positionTranslated.dx * sin + positionTranslated.dy * cos + origin.dy,
    );
  }
}
