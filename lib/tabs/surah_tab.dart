import 'package:al_hafidz/globals.dart';
import 'package:al_hafidz/models/surah.dart';
import 'package:al_hafidz/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan bookmark secara permanen

class SurahTab extends StatefulWidget {
  const SurahTab({super.key});

  @override
  _SurahTabState createState() => _SurahTabState();
}

class _SurahTabState extends State<SurahTab> {
  List<int> bookmarkedSurahs = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<List<Surah>> _getSurahList() async {
    String data = await rootBundle.loadString('assets/datas/list-surah.json');
    return surahFromJson(data);
  }

  Future<void> _loadBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarkedSurahs =
          prefs.getStringList('bookmarkedSurahs')?.map(int.parse).toList() ??
              [];
    });
  }

  Future<void> _toggleBookmark(int surahNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (bookmarkedSurahs.contains(surahNumber)) {
        bookmarkedSurahs.remove(surahNumber); // Hapus jika sudah di-bookmark
      } else {
        bookmarkedSurahs.add(surahNumber); // Tambahkan ke bookmark
      }
    });

    // Simpan perubahan ke SharedPreferences
    await prefs.setStringList(
        'bookmarkedSurahs', bookmarkedSurahs.map((e) => e.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Surah>>(
      future: _getSurahList(),
      initialData: [],
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return ListView.separated(
          itemBuilder: (context, index) => _surahItem(
            context: context,
            surah: snapshot.data!.elementAt(index),
          ),
          separatorBuilder: (context, index) => Divider(
            color: const Color(0xff7b80ad).withOpacity(.35),
          ),
          itemCount: snapshot.data!.length,
        );
      },
    );
  }

  Widget _surahItem({required Surah surah, required BuildContext context}) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailScreen(noSurat: surah.nomor),
            ),
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
                        "${surah.nomor}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
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
                      surah.namaLatin,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          surah.tempatTurun.name,
                          style: GoogleFonts.poppins(
                            color: text,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: text,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${surah.jumlahAyat} Ayat",
                          style: GoogleFonts.poppins(
                            color: text,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    surah.nama,
                    style: GoogleFonts.amiri(
                      color: primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      _toggleBookmark(
                          surah.nomor); // Fungsi untuk toggle bookmark
                    },
                    icon: Icon(
                      bookmarkedSurahs.contains(surah.nomor)
                          ? Icons
                              .bookmark // Ikon bookmark penuh saat di-bookmark
                          : Icons
                              .bookmark_outline, // Ikon bookmark outline saat tidak di-bookmark
                      color: Colors.white, // Warna ikon putih
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
