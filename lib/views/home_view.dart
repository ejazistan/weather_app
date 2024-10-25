import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utilz/utilz.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var controller = TextEditingController();
  Weather? weather;
  List<Weather>? forecast;
  bool isLoading = false;
  bool isCelsius = true;

  @override
  void initState() {
    super.initState();
    fetchCurrentWeather();
  }

  void fetchCurrentWeather() async {
    setState(() {
      isLoading = true;
    });
    WeatherService service = WeatherService();
    var permissions = await service.getPermission();
    if (!permissions) {
      showMsg(
        context: context,
        title: 'Please enable location service and allow permissions.',
      );
      setState(() {
        isLoading = false;
      });
      return;
    }
    var position = await service.getCurrentPosition();
    weather = await service.getWeatherByPosition(position);
    forecast = await service.getForecastByPosition(position);
    setState(() {
      isLoading = false;
    });
  }

  void refreshWeather() {
    fetchCurrentWeather();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  String getImage(String value) {
    switch (value) {
      case 'clear':
      case 'sunny':
        return 'resources/images/clear.png';
      case 'clouds':
        return 'resources/images/clouds.png';
      case 'fog':
        return 'resources/images/foggy.png';
      case 'rain':
        return 'resources/images/rainy.png';
      case 'snow':
        return 'resources/images/snowy.png';
      default:
        return 'resources/images/clear.png';
    }
  }

  void getWeatherByCity() {
    if (controller.text.trim().isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      WeatherService service = WeatherService();
      service.getWeatherByName(controller.text).then(
        (weatherData) {
          weather = weatherData;
          return service.getForecastByName(controller.text);
        },
      ).then((forecastData) {
        setState(() {
          isLoading = false;
          forecast = forecastData;
        });
      }).onError(
        (error, stackTrace) {
          controller.clear();
          showMsg(context: context, title: 'City not found.');
          setState(() {
            isLoading = false;
          });
        },
      );
    }
  }

  void toggleTemperatureUnit() {
    setState(() {
      isCelsius = !isCelsius;
    });
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d, h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[200]!, Colors.blue[300]!],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
        title: const Text('Weather Forecast',
            style: TextStyle(
              fontSize: 30,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white70,
            ),
            onPressed: refreshWeather,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[300]!, Colors.blue[100]!],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Find Your Perfect Weather!',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Search City',
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: getWeatherByCity,
                      icon: const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading) const Center(child: CircularProgressIndicator()),
              if (weather != null && !isLoading)
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  isCelsius
                                      ? '${weather?.temperature?.celsius?.toStringAsFixed(1)} °C'
                                      : '${((weather?.temperature?.celsius ?? 0) * 9 / 5 + 32).toStringAsFixed(1)} °F',
                                  style: const TextStyle(
                                      fontSize: 40, color: Colors.black),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${weather?.weatherMain}',
                                      style: const TextStyle(
                                          fontSize: 30, color: Colors.black),
                                    ),
                                    const SizedBox(width: 20),
                                    Image.asset(
                                      getImage(
                                          weather?.weatherMain?.toLowerCase() ??
                                              'clear'),
                                      width: 50,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Humidity: ${weather?.humidity}% | Wind Speed: ${weather?.windSpeed} m/s',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: toggleTemperatureUnit,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: Text(isCelsius
                                        ? 'Switch to °F'
                                        : 'Switch to °C'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Weekly Weather',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 7, // Show only 7 days of forecast
                          itemBuilder: (context, index) {
                            var dayWeather = forecast![index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              color: const Color.fromARGB(255, 182, 218, 247),
                              shadowColor: Colors.transparent,
                              child: ListTile(
                                title: Text(dayWeather.weatherMain ?? 'N/A'),
                                subtitle: Text(
                                  'Date: ${formatDate(DateTime.now().add(Duration(days: index)))}\n'
                                  'Temp: ${isCelsius ? dayWeather.temperature?.celsius?.toStringAsFixed(1) : (dayWeather.temperature?.celsius ?? 0) * 9 / 5 + 32} °${isCelsius ? 'C' : 'F'}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Image.asset(
                                  getImage(
                                      dayWeather.weatherMain?.toLowerCase() ??
                                          'clear'),
                                  width: 40,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
