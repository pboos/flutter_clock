import 'package:flutter/widgets.dart';

class Landscape {
  // imageLayers

  // starsLayerIndex
  // sunLayerIndex
  // weatherLayerIndex

  // horizon: 0.5 (% from bottom)

  final String landscape;
  final String background;
  final double horizon;

  const Landscape({
    @required this.landscape,
    @required this.background,
    @required this.horizon,
  });
}

const Landscape1 = const Landscape(
  landscape: "landscape1/landscape.png",
  background: "landscape1/background.png",
  horizon: 0.25,
);
const Landscape2 = const Landscape(
  landscape: "landscape2/landscape.png",
  background: "landscape2/background.png",
  horizon: 0.5,
);
