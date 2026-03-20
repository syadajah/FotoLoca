import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fotoloca/screen/login.dart';
import 'package:fotoloca/test_widget.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/custom_button.dart';
import 'package:fotoloca/widget/custom_textfield.dart';
import 'package:fotoloca/widget/product_card.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:fotoloca/services/product_services.dart';

class ProductScreenAdmin extends StatefulWidget {
  const ProductScreenAdmin({super.key});

  @override
  State<ProductScreenAdmin> createState() => _ProductScreenAdminState();
}

class _ProductScreenAdminState extends State<ProductScreenAdmin> {
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
      body: Container(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
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
                          builder: (BuildContext context) => const TestScreen(),
                        ),
                      );
                      _refreshData();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () {},
                  icon: const Iconify(
                    Mdi.tag,
                    color: AppColors.button,
                    size: 24,
                  ),
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
                    return const Center(child: CircularProgressIndicator());
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
                            item['foto_url'] ??
                            'https://via.placeholder.com/400x200?text=No+Image',
                        categoryName:
                            item['category']?['nama_kategori'] ??
                            'Tanpa Kategori',
                        productName: item['nama_produk'] ?? "Tanpa nama",
                        price: 'Rp ${item['harga_produk']}',
                        onTap: () {
                          print(
                            "Produk diklik: ${item['nama_produk']} (ID: ${item['id']})",
                          );
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
