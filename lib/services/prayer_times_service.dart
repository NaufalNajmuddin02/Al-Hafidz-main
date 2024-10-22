import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTimesService {
  final String apiUrl = 'https://api.aladhan.com/v1/timingsByCity?city=Jakarta&country=Indonesia&method=2';

  Future<Map<String, dynamic>> fetchPrayerTimes() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Decode response into a map
      Map<String, dynamic> data = jsonDecode(response.body)['data']['timings'];
      return data;
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}
