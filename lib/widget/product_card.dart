import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String categoryName;
  final String productName;
  final String price;
  final String? tier;
  final VoidCallback? onTap;

  // Fungsi penentu jumlah bintang berdasarkan tier
  int _getStarCount(String? tierLevel) {
    if (tierLevel == 'Exclusive') return 3;
    if (tierLevel == 'Signature') return 2;
    return 1; // Default Essential dapet 1 bintang
  }

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.categoryName,
    required this.productName,
    required this.price,
    this.tier, // <--- 2. MASUKIN KE CONSTRUCTOR
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN GAMBAR YG DIBUNGKUS STACK ---
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 160, // Gw gedein dikit biar bintangnya lega
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, StackTrace) {
                      return Container(
                        height: 160,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),

                // BADGE BINTANG
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        _getStarCount(
                          tier,
                        ), // <--- 3. PANGGIL VARIABEL TIER DI SINI
                        (index) => const Padding(
                          padding: EdgeInsets.only(right: 2.0),
                          child: Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD700),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- BAGIAN TEKS ---
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Shimmer bikin efek cahaya jalan
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!, // Abu-abu gelap (dasar)
      highlightColor: Colors.grey[100]!, // Abu-abu terang (cahaya)
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fake Foto Top (Pastiin tingginya sama 160 biar gak lompat pas datanya dapet)
            Container(
              height: 125,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white, // Shimmer butuh warna buat diefek
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
            ),

            // Fake Teks Teks di bawah foto
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fake Kategori
                  Container(width: 80, height: 13, color: Colors.white),
                  const SizedBox(height: 10),
                  // Fake Nama Produk (Dua baris)
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(width: 200, height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  // Fake Harga
                  Container(width: 100, height: 15, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
