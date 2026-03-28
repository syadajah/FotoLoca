import 'package:flutter/material.dart';
import 'package:fotoloca/screen/admin/products/create_product_admin.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/category_bottom_sheet.dart';
import 'package:fotoloca/widget/custom_button.dart';
import 'package:fotoloca/widget/custom_textfield.dart';
import 'package:fotoloca/widget/product_card.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:fotoloca/services/product_services.dart';
import 'package:fotoloca/screen/admin/products/detail_product_admin.dart';
import 'package:fotoloca/widget/custom_add_on_bottom_sheet.dart';

class ProductScreenAdmin extends StatefulWidget {
  const ProductScreenAdmin({super.key});

  @override
  State<ProductScreenAdmin> createState() => _ProductScreenAdminState();
}

class _ProductScreenAdminState extends State<ProductScreenAdmin> {
  final ProductServices _productServices = ProductServices();
  late Future<List<dynamic>> _productsFuture;
  String _searchQuery = '';
  List<int> _selectedCategories = [];

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
      body: Container(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomTextfield(
                    hintText: "Cari produk...",
                    icon: Icons.search,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 5),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    // MUNCULKAN BOTTOM SHEET DI SINI
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors
                          .transparent, // Wajib transparan biar sudut melengkungnya keliatan
                      builder: (context) => CategoryBottomSheet(
                        // 1. Kasih tau bottom sheet kategori apa yang lagi aktif
                        selectedCategoryIds: _selectedCategories,
                        // 2. Tangkap perubahan saat checkbox diklik
                        onSelectionChanged: (newSelectedIds) {
                          setState(() {
                            _selectedCategories = newSelectedIds;
                          });
                        },
                      ),
                    );
                  },
                  icon: const Iconify(
                    Mdi.tag,
                    color: AppColors.button,
                    size: 24,
                  ),
                  tooltip: 'Kelola kategori',
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 5),
                const SizedBox(height: 10),
                IconButton(
                  icon: const Icon(
                    Icons.extension_rounded,
                    color: AppColors.button,
                  ), // Ikon Puzzle
                  tooltip: 'Kelola Add-ons',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled:
                          true, // Wajib true biar pas ngetik harga gak ketutup keyboard
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AddonBottomSheet(),
                    );
                  },
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Tambah produk baru",
                    hasStroke: true,
                    icon: const Iconify(
                      Mdi.plus,
                      color: AppColors.button,
                      size: 20,
                    ),
                    textColor: Colors.grey,
                    backgroundColor: AppColors.background,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const CreateProductAdmin(),
                        ),
                      );
                      _refreshData();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Katalog",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  //Loading data
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // TAMPILKAN SKELETON LOADING DI SINI 🔥
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount:
                          4, // Kasih 4 kotak palsu aja biar pas penuhi layar
                      itemBuilder: (context, index) {
                        return const ProductCardSkeleton(); // Panggil class Skeleton lu
                      },
                    );
                  } else if (snapshot.hasError) {
                  } else if (snapshot.hasError) {
                    //bila terjadi error di server
                    return Center(
                      child: Text(
                        'Gagal memuat data. \nPastikan server menyala.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red[300]),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    //Data produk masih kosong
                    return const Center(
                      child: Text(
                        'Belum ada produk. \nSilahkan tambahkan produk baru.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  //Data sukses tampil dari server
                  final products = snapshot.data!;

                  //filter data
                  final filteredProducts = products.where((item) {
                    final namaProduk = item['nama_produk']
                        .toString()
                        .toLowerCase();
                    final kataKunci = _searchQuery.toLowerCase();
                    final matchSearch = namaProduk.contains(kataKunci);

                    final int itemCategoryId = item['id_kategori'] ?? 0;

                    final matchCategory =
                        _selectedCategories.isEmpty ||
                        _selectedCategories.contains(itemCategoryId);

                    return matchSearch && matchCategory;
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

                          // Kalau result-nya true (artinya produk baru aja dihapus), refresh data list-nya!
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
    );
  }
}
