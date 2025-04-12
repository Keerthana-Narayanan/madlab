// pubsec yaml file

// name: weather_app
// description: A simple weather app using OpenWeatherMap API.
// publish_to: 'none'
// version: 1.0.0+1

// environment:
//   sdk: ">=3.0.0 <4.0.0"

// dependencies:
//   flutter:
//     sdk: flutter
//   http: ^0.13.6 # for API requests

// dev_dependencies:
//   flutter_test:
//     sdk: flutter

// flutter:
//   uses-material-design: true


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherHome(),
      debugShowCheckedModeBanner: false, // Hides debug banner
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({Key? key}) : super(key: key);

  @override
  _WeatherHomeState createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final String apiKey = "ea4dcff0adc064211a2a8ec7dc448b08"; // Replace with your OpenWeatherMap API key
  String cityName = '';
  double temperature = 0.0;
  String description = '';
  String iconCode = '';
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = data['main']['temp'];
          description = data['weather'][0]['description'];
          iconCode = data['weather'][0]['icon'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "City not found! Please try again.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching weather. Check your internet.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent], // Blue gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Weather App 🌦️',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => cityName = value,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter City Name",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => fetchWeather(cityName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Get Weather"),
                ),
                const SizedBox(height: 30),

                // Show loading indicator
                if (isLoading) const CircularProgressIndicator(color: Colors.white),

                // Show error message if any
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Show weather details only if data is available
                if (!isLoading && errorMessage.isEmpty && temperature != 0.0)
                  Column(
                    children: [
                      Image.network(
                        "https://openweathermap.org/img/wn/$iconCode@2x.png",
                        width: 100,
                        height: 100,
                      ),
                      Text(
                        "${temperature.toStringAsFixed(1)}°C",
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        description.toUpperCase(),
                        style: const TextStyle(fontSize: 20, color: Colors.white70),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
