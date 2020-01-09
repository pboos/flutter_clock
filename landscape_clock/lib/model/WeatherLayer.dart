import 'package:flutter_clock_helper/model.dart';

class WeatherLayer {
  final WeatherCondition condition;
  final String asset;
  final WeatherLayerPosition position;

  const WeatherLayer(this.condition, this.asset, this.position);
}

enum WeatherLayerPosition {
  behindLandscape,
  aboveLandscape,
}

const WeatherLayers = const {
//  WeatherCondition.cloudy: WeatherLayer(
//    WeatherCondition.cloudy,
//    "weather/cloudy.png",
//    WeatherLayerPosition.aboveLandscape,
//  ),
//  WeatherCondition.foggy: WeatherLayer(
//    WeatherCondition.foggy,
//    "weather/foggy.png",
//    WeatherLayerPosition.aboveLandscape,
//  ),
  WeatherCondition.rainy: WeatherLayer(
    WeatherCondition.rainy,
    "weather/rainy.png",
    WeatherLayerPosition.aboveLandscape,
  ),
  WeatherCondition.snowy: WeatherLayer(
    WeatherCondition.snowy,
    "weather/snowy.png",
    WeatherLayerPosition.aboveLandscape,
  ),
  WeatherCondition.sunny: WeatherLayer(
    WeatherCondition.sunny,
    "weather/sunny.png", // sunny2.png
    WeatherLayerPosition.behindLandscape,
  ),
//  WeatherCondition.thunderstorm: WeatherLayer(
//    WeatherCondition.thunderstorm,
//    "weather/thunderstorm.png",
//    WeatherLayerPosition.aboveLandscape,
//  ),
//  WeatherCondition.windy: WeatherLayer(
//    WeatherCondition.windy,
//    "weather/windy.png",
//    WeatherLayerPosition.aboveLandscape,
//  ),
};

WeatherLayer getWeatherLayerForCondition(WeatherCondition condition) {
  // currently defaults with sunny (for those not yet implemented above)
  return WeatherLayers[condition] ?? WeatherLayers[WeatherCondition.sunny];
}
