import 'package:flutter/material.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/custom_textfield.dart';
import 'package:fotoloca/widget/product_card.dart';
import 'package:fotoloca/services/product_services.dart';
import 'package:fotoloca/screen/admin/products/detail_product_admin.dart';

class ProductScreenOwner extends StatefulWidget {
  const ProductScreenOwner({super.key});

  @override
  State<ProductScreenOwner> createState() => _ProductScreenOwnerState();
}

class _ProductScreenOwnerState extends State<ProductScreenOwner> {
  final ProductServices _productServices = ProductServices();
  late Future<List<dynamic>> _productsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _productsFuture = _productServices.showProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEARCH BAR LEBIH CLEAN (TANPA ROW YANG TIDAK PERLU) ---
              CustomTextfield(
                hintText: "Cari produk...",
                icon: Icons.search,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              const Text(
                "Katalog",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    // Loading data
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return const ProductCardSkeleton();
                        },
                      );
                    } else if (snapshot.hasError) {
                      // Bila terjadi error di server
                      return Center(
                        child: Text(
                          'Gagal memuat data. \nPastikan server menyala.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red[300]),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      // Data produk masih kosong
                      return const Center(
                        child: Text(
                          'Belum ada produk. \nSilahkan tambahkan produk baru.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    // Data sukses tampil dari server
                    final products = snapshot.data!;

                    // OPTIMALISASI: toLowerCase cuma dipanggil 1x sebelum masuk looping
                    final kataKunci = _searchQuery.toLowerCase();

                    // Filter data
                    final filteredProducts = products.where((item) {
                      final namaProduk =
                          item['nama_produk']?.toString().toLowerCase() ?? '';
                      return namaProduk.contains(kataKunci);
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return const Center(
                        child: Text(
                          "Produk tidak ditemukan.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
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
                          productName: item['nama_produk'] ?? "Tanpa nama",
                          price: 'Rp ${item['harga_produk']}',
                          tier: item['tier_level'],
                          onTap: () async {
                            // Tunggu sampai halaman detail ditutup
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailProductAdmin(productData: item),
                              ),
                            );

                            // Kalau result-nya true (artinya produk baru aja dihapus/diupdate), refresh data list-nya!
                            if (result == true) {
                              _refreshData();
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
