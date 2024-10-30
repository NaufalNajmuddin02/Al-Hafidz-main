import 'dart:async';
import 'package:al_hafidz/globals.dart';
import 'package:al_hafidz/screens/doa_page.dart';
import 'package:al_hafidz/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/prayer_times_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  Map<String, dynamic>? prayerTimes;
  bool isLoading = true;
  int _selectedIndex = 0;
  DateTime currentTime = DateTime.now();
  Timer? timer;

  final List<String> prayerNames = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
  final List<String> customPrayerNames = [
    "Subuh",
    "Dzuhur",
    "Asar",
    "Maghrib",
    "Isya"
  ]; // Custom names

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes();
    startClock();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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

  void startClock() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateTime.now();
      });
    });
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PrayerTimesScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoaPage()),
        );
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text(
          'Jadwal Sholat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: background,
      body: Stack(
        children: [
          Container(
            color: const Color(0xFF040C23),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 32.0),
                  itemCount: prayerNames.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return buildCurrentTimeCard(); // Styled clock
                    } else if (index == 1) {
                      return SizedBox(height: 100);
                    }
                    String originalName = prayerNames[index - 2];
                    String displayName =
                        customPrayerNames[index - 2]; // Display custom name
                    String time = prayerTimes![originalName] ?? "-";
                    return buildPrayerTimeRow(displayName, time);
                  },
                ),
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  BottomNavigationBar _bottomNavigationBar() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: gray,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          _bottomBarItem(icon: "assets/svgs/quran-icon.svg", label: "Quran"),
          _bottomBarItem(icon: "assets/svgs/lamp-icon.svg", label: "Tips"),
          _bottomBarItem(icon: "assets/svgs/pray-icon.svg", label: "Prayer"),
          _bottomBarItem(icon: "assets/svgs/doa-icon.svg", label: "Doa"),
          _bottomBarItem(
              icon: "assets/svgs/bookmark-icon.svg", label: "Bookmark"),
        ],
      );

  BottomNavigationBarItem _bottomBarItem(
          {required String icon, required String label}) =>
      BottomNavigationBarItem(
        icon: SvgPicture.asset(
          icon,
          color: text,
        ),
        activeIcon: SvgPicture.asset(
          icon,
          color: primary,
        ),
        label: label,
      );

  Widget buildCurrentTimeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}:${currentTime.second.toString().padLeft(2, '0')}",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPrayerTimeRow(String name, String time) {
    return Card(
      color: const Color(0xFF121931),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        trailing: Text(
          time,
          style: GoogleFonts.poppins(
            color: const Color(0xFFA19CC5),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
