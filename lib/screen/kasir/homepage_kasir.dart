import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fotoloca/screen/kasir/detail_product_cashier.dart';
import 'package:fotoloca/screen/login.dart';
import 'package:fotoloca/services/auth_service.dart';
import 'package:fotoloca/services/product_services.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/custom_card_ads.dart';
import 'package:fotoloca/widget/custom_textfield.dart';
import 'package:fotoloca/widget/product_card.dart';
import 'package:fotoloca/widget/related_product_skeleton.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart'; // Sesuaikan sama import skeleton lu

class HomepageKasir extends StatefulWidget {
  const HomepageKasir({super.key});

  @override
  State<HomepageKasir> createState() => _HomepageKasirState();
}

class _HomepageKasirState extends State<HomepageKasir> {
  final ProductServices _productServices = ProductServices();
  late Future<List<dynamic>> _productsFuture;

  String _searchQuery = '';
  String _kasirName = 'Kasir'; // Buat nampung nama kasir

  @override
  void initState() {
    super.initState();
    _refreshData();
    _loadKasirName();
  }

  // Tarik data nama kasir dari Secure Storage
  Future<void> _loadKasirName() async {
    const storage = FlutterSecureStorage();
    final name = await storage.read(key: 'user_name');
    if (name != null && mounted) {
      setState(() => _kasirName = name);
    }
  }

  void _refreshData() {
    setState(() {
      _productsFuture = _productServices.showProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF9F9F9,
      ), // Background abu-abu muda kayak desain
      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // 1. BAGIAN ATAS (TETAP MENGGANTUNG / TIDAK IKUT SCROLL)
            // =================================================================
            Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 20.0,
                bottom: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Sapaan & Tombol Logout ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat datang, $_kasirName!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Layani pelanggan dengan senang hati ✨',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Search Bar & History ---
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextfield(
                          hintText: "Telusuri...",
                          icon: Icons.search,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Tombol History Bundar Sesuai Desain
                      IconButton(
                        onPressed: () {
                          // TODO: Arahkan ke halaman history
                        },
                        icon: const Iconify(
                          Mdi.history,
                          color: AppColors.button,
                          size: 24,
                        ),
                        tooltip: 'Log aktivitas',
                        style: IconButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFE0E0E0),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // =================================================================
            // 2. BAGIAN BAWAH (IKUT SCROLL BARENGAN)
            // =================================================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(), // Efek mantul kayak iOS
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),

                      // --- Banner Iklan ---
                      const CustomCardAds(),
                      const SizedBox(height: 25),

                      // --- Judul Katalog ---
                      const Text(
                        "Katalog",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // --- Future Builder List Produk ---
                      FutureBuilder<List<dynamic>>(
                        future: _productsFuture,
                        builder: (context, snapshot) {
                          // Loading data
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListView.builder(
                              shrinkWrap:
                                  true, // WAJIB ADA BIAR BISA DI DALAM SCROLLVIEW
                              physics:
                                  const NeverScrollableScrollPhysics(), // WAJIB ADA
                              padding: EdgeInsets.zero,
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                // Ganti pakai Skeleton Class lu (misal ProductCardSkeleton / RelatedProductSkeleton)
                                return const ProductCardSkeleton();
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'Gagal memuat data.\n${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red[300]),
                                ),
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Text(
                                  'Belum ada produk.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          }

                          final products = snapshot.data!;

                          // Filter data
                          final filteredProducts = products.where((item) {
                            final namaProduk = item['nama_produk']
                                .toString()
                                .toLowerCase();
                            final kataKunci = _searchQuery.toLowerCase();
                            return namaProduk.contains(kataKunci);
                          }).toList();

                          if (filteredProducts.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Text(
                                  "Produk tidak ditemukan.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true, // WAJIB ADA
                            physics:
                                const NeverScrollableScrollPhysics(), // Biar scroll-nya diambil alih SingleChildScrollView
                            padding: EdgeInsets.only(bottom: 20),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final item = filteredProducts[index];
                              return ProductCard(
                                imageUrl:
                                    item['foto'] ??
                                    'https://via.placeholder.com/400x200?text=No+Image',
                                categoryName:
                                    item['category']?['nama_kategori'] ??
                                    'Tanpa Kategori',
                                productName:
                                    item['nama_produk'] ?? "Tanpa nama",
                                price: 'Rp ${item['harga_produk']}',
                                tier: item['tier_level'],
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailProductKasir(productData: item),
                                    ),
                                  );

                                  if (result == true) {
                                    _refreshData();
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
