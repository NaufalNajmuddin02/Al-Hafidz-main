import 'package:flutter/material.dart';
import '../services/prayer_times_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  Map<String, dynamic>? prayerTimes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes();
  }

  Future<void> fetchPrayerTimes() async {
    try {
      Map<String, dynamic> times = await _prayerTimesService.fetchPrayerTimes();
      setState(() {
        prayerTimes = times;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prayer Times'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : prayerTimes != null
              ? ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    buildPrayerTimeRow("Fajr", prayerTimes!['Fajr']),
                    buildPrayerTimeRow("Dhuhr", prayerTimes!['Dhuhr']),
                    buildPrayerTimeRow("Asr", prayerTimes!['Asr']),
                    buildPrayerTimeRow("Maghrib", prayerTimes!['Maghrib']),
                    buildPrayerTimeRow("Isha", prayerTimes!['Isha']),
                    buildPrayerTimeRow("Sunrise", prayerTimes!['Sunrise']),
                    buildPrayerTimeRow("Sunset", prayerTimes!['Sunset']),
                  ],
                )
              : Center(
                  child: Text('Failed to load prayer times'),
                ),
    );
  }

  Widget buildPrayerTimeRow(String name, String time) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(name),
        trailing: Text(time),
      ),
    );
  }
}
