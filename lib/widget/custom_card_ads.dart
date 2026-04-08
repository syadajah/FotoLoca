import 'package:flutter/material.dart';

class CustomCardAds extends StatelessWidget {
  const CustomCardAds({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 130,
      // --- FIX: clipBehavior ditaruh di sini, punyanya Container ---
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xff5c5c5c), // Abu-abu gelap (Dark Charcoal)
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5), // Posisi bayangan
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .stretch, // Membuat anak-anak Row memiliki tinggi penuh
        children: [
          // Kolom Kiri: Teks dengan Padding internal
          Expanded(
            flex: 4, // Mengambil 60% lebar kartu
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                bottom: 10.0,
              ), // Padding internal untuk teks
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FotoLoca',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Setiap momen punya cerita, Biarkan kami yang mengabadikannya.',
                    style: TextStyle(
                      color: Color(0xFFE0E0E0), // Abu-abu terang
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Kolom Kanan: Ilustrasi Kamera dan Pria (Full Right dan Bottom)
          Expanded(
            flex: 2, // Mengambil 40% lebar kartu
            child: Stack(
              clipBehavior:
                  Clip.none, // Membiarkan item dalam stack meluap jika perlu
              children: [
                // Tumpukan Foto Polaroid (Latar Belakang)
                Positioned(
                  top: 25,
                  right: 15,
                  child: Transform.rotate(
                    angle: -0.2, // Putar sedikit ke kiri
                    child: Container(
                      width: 50,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 30,
                  child: Transform.rotate(
                    angle: -0.4, // Putar lebih ke kiri
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
                // Pria Kartun Memegang Kamera (Bleeding off right and bottom)
                Positioned(
                  right: 0, // Mepet kanan
                  bottom:
                      -15, // Mepet bawah (sedikit offset untuk efek bleeding)
                  child: Image.asset(
                    'assets/images/pana.png', // Gambar pria dan kamera lu
                    height: 120, // Tinggi penuh kartu
                    fit: BoxFit
                        .fitHeight, // Sesuaikan tinggi agar mengisi vertikal
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
