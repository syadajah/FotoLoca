import 'package:flutter/material.dart';
import 'package:fotoloca/services/product_services.dart';
import 'package:fotoloca/widget/related_product_skeleton.dart';
import 'package:fotoloca/widget/transaction_bottom_sheet.dart';

// 1. UBAH JADI STATEFUL WIDGET BIAR BISA PAKAI INITSTATE
class DetailProductKasir extends StatefulWidget {
  final Map<String, dynamic> productData;

  const DetailProductKasir({super.key, required this.productData});

  @override
  State<DetailProductKasir> createState() => _DetailProductKasirState();
}

class _DetailProductKasirState extends State<DetailProductKasir> {
  // 2. BIKIN VARIABEL PENAMPUNG FUTURE BIAR GAK DI-SPAM
  late Future<List<dynamic>> _categoriesFuture;
  late Future<List<dynamic>> _relatedFuture;

  @override
  void initState() {
    super.initState();
    // 3. TEMBAK API CUKUP 1 KALI SAJA PAS HALAMAN DIBUKA
    _categoriesFuture = ProductServices().getCategories();
    _relatedFuture = Future.wait([
      ProductServices().showProducts(),
      ProductServices()
          .getCategories(), // Pakai _categoriesFuture juga bisa sbenernya, tp gini jg gpp
    ]);
  }

  // --- HELPER: Format Rupiah ---
  String formatRupiah(int number) {
    String numberStr = number.toString();
    String result = '';
    int count = 0;
    for (int i = numberStr.length - 1; i >= 0; i--) {
      result = numberStr[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.productData['foto'] ?? '';
    final String namaProduk =
        widget.productData['nama_produk'] ?? 'Nama Produk';
    final String deskripsi =
        widget.productData['deskripsi'] ?? 'Deskripsi tidak tersedia.';
    final String tier = widget.productData['tier_level'] ?? 'Essential';
    final int harga =
        int.tryParse(widget.productData['harga_produk'].toString()) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(context),
      bottomNavigationBar: _buildBottomNav(
        context,
        namaProduk,
        widget.productData,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainProductCard(imageUrl, namaProduk, deskripsi),
              const SizedBox(height: 10),

              // KOTAK INFO DETAIL (Kategori, Tier, Harga)
              _buildInfoBox(tier, harga),
              const SizedBox(height: 25),

              const Divider(color: Colors.grey, thickness: 0.5),
              const SizedBox(height: 25),

              const Text(
                "Rekomendasi paket lain dari kategori serupa",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              // LIST REKOMENDASI PRODUK
              _buildRelatedProductsList(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9F9),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Detail",
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      titleSpacing: 0,
    );
  }

  // 2. Tombol Pesan Sekarang (Bottom Nav)
  Widget _buildBottomNav(
    BuildContext context,
    String namaProduk,
    Map<String, dynamic> product,
  ) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) {
              return TransactionBottomSheet(
                productData: product,
                categoryName: "Paket Terpilih",
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF5A5A5A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          "Pesan Sekarang",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // 3. Card Foto & Deskripsi
  Widget _buildMainProductCard(
    String imageUrl,
    String namaProduk,
    String deskripsi,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaProduk,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  deskripsi,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Kotak Info (Kategori, Tier, Harga)
  Widget _buildInfoBox(String tier, int harga) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          FutureBuilder<List<dynamic>>(
            // 4. PANGGIL VARIABEL FUTURE-NYA DI SINI
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildInfoRow("Kategori", "Loading...", false);
              }
              String realCategoryName = "Kategori Tidak Diketahui";
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                try {
                  final catMatch = snapshot.data!.firstWhere(
                    (c) =>
                        c['id'].toString() ==
                        widget.productData['id_kategori'].toString(),
                  );
                  realCategoryName = catMatch['nama_kategori'];
                } catch (e) {}
              }
              return _buildInfoRow("Kategori", realCategoryName, false);
            },
          ),
          const SizedBox(height: 12),
          _buildInfoRow("Tier Paket", tier, false),
          const SizedBox(height: 12),
          _buildInfoRow("Harga", formatRupiah(harga), true),
        ],
      ),
    );
  }

  // 5. Future Builder List Rekomendasi
  Widget _buildRelatedProductsList() {
    return FutureBuilder<List<dynamic>>(
      // 5. PANGGIL VARIABEL FUTURE-NYA DI SINI JUGA
      future: _relatedFuture,
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: RelatedProductSkeleton());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Text(
            "Gagal memuat data.",
            style: TextStyle(color: Colors.grey),
          );
        }

        final List<dynamic> allProducts = snapshot.data![0] ?? [];
        final List<dynamic> allCategories = snapshot.data![1] ?? [];

        final currentProductId = widget.productData['id'];
        final currentCategoryId = widget.productData['id_kategori'];

        final relatedProducts = allProducts.where((p) {
          return p['id_kategori'].toString() == currentCategoryId.toString() &&
              p['id'].toString() != currentProductId.toString();
        }).toList();

        if (relatedProducts.isEmpty) {
          return const Text(
            "Belum ada paket lain di kategori ini.",
            style: TextStyle(color: Colors.grey),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: relatedProducts.length,
          itemBuilder: (context, index) {
            final product = relatedProducts[index];
            String realCategoryName = "Kategori";
            try {
              final catMatch = allCategories.firstWhere(
                (c) => c['id'].toString() == product['id_kategori'].toString(),
              );
              realCategoryName = catMatch['nama_kategori'];
            } catch (e) {}

            return _buildRelatedProductCard(
              name: product['nama_produk'] ?? 'Unknown',
              category: realCategoryName,
              price: int.tryParse(product['harga_produk'].toString()) ?? 0,
              imageUrl: product['foto'] ?? '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailProductKasir(productData: product),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, bool isPrice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
            color: isPrice ? const Color(0xFFD4AF37) : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildRelatedProductCard({
    required String name,
    required String category,
    required int price,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 100,
                height: 70,
                color: Colors.grey.shade200,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                      )
                    : const Icon(Icons.camera_alt, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatRupiah(price),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
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
