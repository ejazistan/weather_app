import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

class WeatherService {
  final WeatherFactory _factory = WeatherFactory('');

  Future<Weather> getWeatherByName(String city) async {
    return await _factory.currentWeatherByCityName(city);
  }

  Future<List<Weather>> getForecastByName(String city) async {
    return await _factory.fiveDayForecastByCityName(city);
  }

  Future<Weather> getWeatherByPosition(Position position) async {
    return await _factory.currentWeatherByLocation(
        position.latitude, position.longitude);
  }

  Future<List<Weather>> getForecastByPosition(Position position) async {
    return await _factory.fiveDayForecastByLocation(
        position.latitude, position.longitude);
  }

  Future<bool> getPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
