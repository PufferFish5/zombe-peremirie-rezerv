import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?latitude=$lat&longitude=$lon&current_weather=true'
      );
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'temp': data['current_weather']['temperature'],
          'code': data['current_weather']['weathercode'],
        };
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  String getWeatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '☁️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    return '⛈️';
  }
}