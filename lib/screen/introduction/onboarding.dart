import 'package:flutter/material.dart';
import 'package:fotoloca/screen/login.dart';
import 'package:fotoloca/utils/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Selamat datang di Tim Kreatif Kami",
      "text":
          "Mari ciptakan karya terbaik bersama. Aplikasi ini adalah asisten pribadi anda untuk setiap sesi pemotretan.",
      "image": "assets/images/onboard1.png",
    },
    {
      "title": "Kendali Penuh di Ujung Jari",
      "text":
          "Kelola seluruh penugasan foto, dari persiapan hingga selesai, hanya dalam satu aplikasi terpadu.",
      "image": "assets/images/onboard2.png",
    },
    {
      "title": "Pantau Pendapatan & Performa",
      "text":
          "Lihat rekap penghasilan, komisi, dan bonus Anda secara real-time untuk setiap proyek yang telah diselesaikan..",
      "image": "assets/images/onboard3.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  // 🔥 DIUBAH: Kirim path gambar (image)
                  image: onboardingData[index]["image"]!,
                  title: onboardingData[index]["title"]!,
                  text: onboardingData[index]["text"]!,
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingData.length,
                        (index) => buildDot(index: index),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.button,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              15,
                            ), // Lebih modern
                          ),
                        ),
                        onPressed: () {
                          if (_currentPage == onboardingData.length - 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                            );
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        },
                        child: Text(
                          _currentPage == onboardingData.length - 1
                              ? "Mulai Sekarang"
                              : "Lanjut",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.button
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  //Content onboard pada PageView
  final String image, title, text;

  const OnboardingContent({
    super.key,
    required this.image,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.end, // Atur posisi ke bawah agar rapi dengan gambar
      children: [
        // 🔥 DIUBAH: Ganti widget Text (Emoji) menjadi Image.asset
        Image.asset(
          image,
          height: 250, // Atur tinggi gambar agar pas di layar
          fit: BoxFit.contain, // Memastikan gambar tidak terpotong
        ),
        const SizedBox(height: 60), // Beri jarak antara gambar dan teks
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.headerFonts,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.captionFonts,
              height: 1.5, // Mengatur spasi antar baris teks agar enak dibaca
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
