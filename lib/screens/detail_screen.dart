import 'dart:convert';
import 'package:al_hafidz/globals.dart';
import 'package:al_hafidz/models/ayat.dart';
import 'package:al_hafidz/models/surah.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class DetailScreen extends StatefulWidget {
  final int noSurat;
  const DetailScreen({super.key, required this.noSurat});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Set<int> _bookmarkedAyat = {}; // Menyimpan nomor ayat yang di-bookmark

  @override
  void initState() {
    super.initState();
    _loadBookmarks(); // Load bookmarks ketika aplikasi dibuka
  }

  // Fungsi untuk memuat bookmark dari SharedPreferences
  Future<void> _loadBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? bookmarkedAyatStrings = prefs.getStringList('bookmarkedAyat');

    if (bookmarkedAyatStrings != null) {
      setState(() {
        _bookmarkedAyat =
            bookmarkedAyatStrings.map((e) => int.parse(e)).toSet();
      });
    }
  }

  // Fungsi untuk menyimpan bookmark ke SharedPreferences
  Future<void> _saveBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarkedAyatStrings =
        _bookmarkedAyat.map((e) => e.toString()).toList();
    await prefs.setStringList('bookmarkedAyat', bookmarkedAyatStrings);
  }

  // Fungsi untuk toggle bookmark
  void _toggleBookmark(int nomorAyat) {
    setState(() {
      if (_bookmarkedAyat.contains(nomorAyat)) {
        _bookmarkedAyat.remove(nomorAyat); // Hapus bookmark jika sudah ada
      } else {
        _bookmarkedAyat.add(nomorAyat); // Tambahkan ke bookmark
      }
    });
    _saveBookmarks(); // Simpan bookmark setelah diubah
  }

  Future<Surah> _getDetailSurah() async {
    var data = await Dio().get("https://equran.id/api/surat/${widget.noSurat}");
    return Surah.fromJson(json.decode(data.toString()));
  }

  void _togglePlay(String url) async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(url));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Surah>(
      future: _getDetailSurah(),
      initialData: null,
      builder: (dynamic context, dynamic snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: background,
          );
        }
        Surah surah = snapshot.data!;
        return Scaffold(
          backgroundColor: background,
          appBar: _appbar(context: context, surah: surah),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: _details(Surah: surah),
              )
            ],
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView.separated(
                itemBuilder: (context, index) => _ayatItem(
                  ayat: surah.ayat!
                      .elementAt(index + (widget.noSurat == 1 ? 1 : 0)),
                ),
                itemCount: surah.jumlahAyat + (widget.noSurat == 1 ? -1 : 0),
                separatorBuilder: (context, index) => Container(),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _togglePlay(surah.audio), // Memutar audio surat
            child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          ),
        );
      },
    );
  }

  Widget _ayatItem({required Ayat ayat}) => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: gray, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(27 / 2)),
                    child: Center(
                      child: Text(
                        '${ayat.nomor}',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(
                    width: 16,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  // Tombol bookmark
                  IconButton(
                    icon: Icon(
                      _bookmarkedAyat.contains(ayat.nomor)
                          ? Icons
                              .bookmark // Jika sudah di-bookmark, tampilkan bookmark penuh
                          : Icons
                              .bookmark_outline, // Jika belum, tampilkan bookmark kosong
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        _toggleBookmark(ayat.nomor), // Fungsi toggle bookmark
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Text(
              ayat.ar,
              style: GoogleFonts.amiri(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              textAlign: TextAlign.right,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              ayat.idn,
              style: GoogleFonts.poppins(color: text, fontSize: 16),
            )
          ],
        ),
      );

  AppBar _appbar({required BuildContext context, required Surah surah}) =>
      AppBar(
        backgroundColor: background,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: SvgPicture.asset('assets/svgs/back-icon.svg'),
            ),
            const SizedBox(
              width: 24,
            ),
            Text(
              surah.namaLatin,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset('assets/svgs/search-icon.svg'),
            ),
          ],
        ),
      );

  Widget _details({required Surah Surah}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          children: [
            Container(
              height: 257,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, .6, 1],
                  colors: [
                    Color(0xffdf98fa),
                    Color(0xffb070fd),
                    Color(0xff9055ff)
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Opacity(
                opacity: .2,
                child: SvgPicture.asset(
                  'assets/svgs/quran.svg',
                  width: 324 - 55,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Text(
                    Surah.namaLatin,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    Surah.arti,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ayat : ${Surah.jumlahAyat}',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Text(
                        Surah.tempatTurun.name,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      );
}
