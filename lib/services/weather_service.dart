import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherResult {
  final double tempC;
  final int rainProb;

  WeatherResult({required this.tempC, required this.rainProb});
}

class WeatherService {
  Future<WeatherResult> fetchWeather(double lat, double lng) async {
    final url =
        "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current=temperature_2m,precipitation_probability";
    final res = await http.get(Uri.parse(url));
    final json = jsonDecode(res.body);

    final current = json["current"];
    final temp = (current["temperature_2m"] as num).toDouble();
    final rainProb = (current["precipitation_probability"] as num).toInt();

    return WeatherResult(tempC: temp, rainProb: rainProb);
  }

  String clothingSuggestion(double tempC, int rainProb) {
    if (rainProb >= 40) return "Take an umbrella and water-resistant shoes.";
    if (tempC < 12) return "Wear a jacket and layers.";
    if (tempC < 18) return "Light jacket or hoodie.";
    if (tempC < 26) return "T-shirt weather.";
    return "Hot day — light clothes + water.";
  }
}
