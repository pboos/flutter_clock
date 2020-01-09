import 'dart:ui';

class Landscape {
  // imageLayers

  // starsLayerIndex
  // sunLayerIndex
  // weatherLayerIndex

  // horizon: 0.5 (% from bottom)

  final String landscape;
  final double horizon;

  final Color colorSkyDay;

  const Landscape(this.landscape, this.horizon, {this.colorSkyDay});
}

const Landscape1 = const Landscape("landscape1/landscape.png", 0.25, colorSkyDay: Color(0xFFDC9424));
const Landscape2 = const Landscape("landscape2.png", 0.25);
const Landscape3 = const Landscape("landscape3.png", 0.25);