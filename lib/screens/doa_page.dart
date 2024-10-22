import 'package:al_hafidz/globals.dart';
import 'package:al_hafidz/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' as rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoaPage extends StatefulWidget {
  @override
  _DoaPageState createState() => _DoaPageState();
}

class _DoaPageState extends State<DoaPage> {
  List<dynamic> doas = [];
  List<int> bookmarkedDoas = [];
  bool isLoading = true;
  Color titleColor = const Color.fromARGB(255, 255, 255, 255); // Warna judul
  int _selectedIndex = 3; // Default selected index for Doa page

  @override
  void initState() {
    super.initState();
    fetchDoa();
    _loadBookmarks();
  }

  // Fungsi untuk mengambil data doa dari file JSON lokal
  Future<void> fetchDoa() async {
    try {
      final String response =
          await rootBundle.rootBundle.loadString('assets/doa.json');
      final data = json.decode(response);
      setState(() {
        doas = data;
        isLoading = false;
      });
    } catch (e) {
      throw Exception('Failed to load doa');
    }
  }

  // Fungsi untuk memuat bookmark yang disimpan
  Future<void> _loadBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarkedDoas =
          prefs.getStringList('bookmarkedDoas')?.map(int.parse).toList() ?? [];
    });
  }

  // Fungsi untuk toggle bookmark
  Future<void> _toggleBookmark(int doaNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (bookmarkedDoas.contains(doaNumber)) {
        bookmarkedDoas.remove(doaNumber);
      } else {
        bookmarkedDoas.add(doaNumber);
      }
    });

    await prefs.setStringList(
        'bookmarkedDoas', bookmarkedDoas.map((e) => e.toString()).toList());
  }

  // Fungsi untuk mengubah halaman saat menekan tombol navigasi
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen()), 
        );
        break;
      case 1:
        Navigator.pushReplacementNamed(
            context, '/tipsPage'); 
        break;
      case 2:
        Navigator.pushReplacementNamed(
            context, '/prayerPage'); 
        break;
      case 3:
        // Doa Page - current page
        break;
      case 4:
        Navigator.pushReplacementNamed(
            context, '/bookmarkPage'); 
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Doa Harian',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: doas.length,
              separatorBuilder: (context, index) => Divider(
                  color: const Color.fromARGB(255, 255, 255, 255)
                      .withOpacity(0.5)),
              itemBuilder: (context, index) {
                return _doaItem(
                    doa: doas[index], index: index, context: context);
              },
            ),
      bottomNavigationBar:
          _bottomNavigationBar(), 
    );
  }

  BottomNavigationBar _bottomNavigationBar() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: gray, // Adjust as needed
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Navigate on tap
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

  Widget _doaItem(
      {required dynamic doa,
      required int index,
      required BuildContext context}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoaDetailPage(doa: doa)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SvgPicture.asset('assets/svgs/nomor-surah.svg'),
                SizedBox(
                  height: 36,
                  width: 36,
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doa['doa'],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _toggleBookmark(index);
              },
              icon: Icon(
                bookmarkedDoas.contains(index)
                    ? Icons.bookmark
                    : Icons.bookmark_outline,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoaDetailPage extends StatelessWidget {
  final dynamic doa;

  DoaDetailPage({required this.doa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          doa['doa'],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.grey[900]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    color: const Color(0xFF121931),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              doa['doa'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFA44AFF),
                                fontFamily: 'Lobster',
                              ),
                            ),
                          ),
                          Divider(
                            color: const Color(0xFFA44AFF),
                            thickness: 1.5,
                          ),
                          SizedBox(height: 16),
                          Text(
                            doa['ayat'],
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontSize: 25,
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            doa['latin'],
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 18, color: const Color(0xFFA19CC5)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            doa['artinya'],
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
