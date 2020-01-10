import 'package:flutter/widgets.dart';

class Landscape {
  final String landscape;
  final LandscapeBackground background;
  final double horizon; // 0.5 = 50%% from bottom

  const Landscape({
    @required this.landscape,
    @required this.background,
    @required this.horizon,
  });
}

const Landscape1 = const Landscape(
  landscape: "landscape1/landscape.png",
  background: GradientLandscapeBackground(
    colorTop: Color(0xFF8FC3EC),
    colorBottom: Color(0xFFFFFFFF),
  ),
  horizon: 0.3,
);
const Landscape2 = const Landscape(
  landscape: "landscape2/landscape.png",
  background: ImageLandscapeBackground("landscape2/background.png"),
  horizon: 0.25,
);
const Landscape3 = const Landscape(
  landscape: "landscape3/landscape.png",
  background: ImageLandscapeBackground("landscape3/background.png"),
  horizon: 0.5,
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
