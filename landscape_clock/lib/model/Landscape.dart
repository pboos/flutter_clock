// Copyright 2020 Patrick Boos. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

class Landscape {
  final String landscape;
  final LandscapeBackground background;
  final double horizon; // 0.3 = 30%% from bottom

  const Landscape({
    @required this.landscape,
    @required this.background,
    @required this.horizon,
  });
}


const Landscape1 = const Landscape(
  landscape: "landscape/landscape.png",
  background: GradientLandscapeBackground(
    colorTop: Color(0xFF9DCFFF), // blue
    colorBottom: Color(0xFFFFFFFF),
  ),
  horizon: 0.3,
);

///////////////////////////////////////////

class LandscapeBackground {
  const LandscapeBackground();
}

class ImageLandscapeBackground extends LandscapeBackground {
  final String asset;

  const ImageLandscapeBackground(this.asset);
}

class GradientLandscapeBackground extends LandscapeBackground {
  final Color colorTop;
  final Color colorBottom;

  const GradientLandscapeBackground({this.colorTop, this.colorBottom});
}
