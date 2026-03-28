import 'package:flutter/material.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/custom_textfield.dart';
import 'package:fotoloca/services/product_services.dart';
import 'package:fotoloca/screen/admin/products/edit_product_admin.dart';

class DetailProductAdmin extends StatefulWidget {
  // 1. Menerima data produk operan dari halaman List
  final Map<String, dynamic> productData;

  const DetailProductAdmin({super.key, required this.productData});

  @override
  State<DetailProductAdmin> createState() => _DetailProductAdminState();
}

class _DetailProductAdminState extends State<DetailProductAdmin> {
  // 2. Siapkan Controller untuk mengisi input field
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // 3. Langsung isi semua controller dengan data bawaan dari database
    _nameController = TextEditingController(
      text: widget.productData['nama_produk'] ?? 'Tanpa Nama',
    );
    // Ambil nama kategori dari relasi JSON
    _categoryController = TextEditingController(
      text:
          widget.productData['category']?['nama_kategori'] ?? 'Tanpa Kategori',
    );
    _priceController = TextEditingController(
      text: widget.productData['harga_produk']?.toString() ?? '0',
    );
    _descriptionController = TextEditingController(
      text: widget.productData['deskripsi'] ?? 'Tidak ada deskripsi',
    );
  }

  // --- FUNGSI MUNCULIN POP-UP KONFIRMASI HAPUS PRODUK ---
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // User nggak bisa tutup pop-up sembarangan pas lagi loading
      builder: (context) {
        bool isDeleting = false; // Variabel loading khusus untuk pop-up ini

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFFF9F9F9),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      size: 50,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Hapus Produk?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Apakah kamu yakin ingin menghapus produk "${widget.productData['nama_produk']}"?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // --- TOMBOL BATAL ---
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isDeleting
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                            child: const Text(
                              "Batal",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // --- TOMBOL HAPUS ---
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isDeleting
                                ? null
                                : () async {
                                    // 1. Nyalakan loading muter
                                    setStateDialog(() => isDeleting = true);

                                    // 2. Tembak API Laravel
                                    final result = await ProductServices()
                                        .deleteProduct(
                                          widget.productData['id'],
                                        );

                                    // 3. Matikan loading muter
                                    setStateDialog(() => isDeleting = false);

                                    if (!context.mounted) return;

                                    if (result['success']) {
                                      // Tutup Pop-Up Dialog
                                      Navigator.pop(context);

                                      // Tutup Halaman Detail dan kirim sinyal 'true' ke halaman sebelumnya
                                      Navigator.pop(context, true);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(result['message']),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      // Kalau gagal, tutup dialog aja, jangan tutup halaman detailnya
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(result['message']),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: isDeleting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Hapus"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Detail Produk",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SLOT IMAGE (Langsung nampilin gambar utuh) ---
              Center(
                child: Container(
                  width: double.infinity,
                  height: 250, // Agak lebih tinggi biar gambarnya puas dilihat
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      widget.productData['foto'] ??
                          'https://via.placeholder.com/400x200?text=No+Image',
                      fit: BoxFit.cover,
                      // Jaga-jaga kalau link gambar rusak
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- INPUT NAMA PRODUK (Read-Only) ---
              const Text(
                "Nama Produk",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              // IgnorePointer bikin formnya gak bisa diklik/diketik
              IgnorePointer(
                child: CustomTextfield(
                  controller: _nameController,
                  hintText: "",
                ),
              ),
              const SizedBox(height: 20),

              // --- KATEGORI PRODUK (Read-Only) ---
              // Daripada pakai dropdown, kita ubah jadi textfield biasa khusus buat view
              const Text(
                "Kategori Produk",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              IgnorePointer(
                child: CustomTextfield(
                  controller: _categoryController,
                  hintText: "",
                ),
              ),
              const SizedBox(height: 20),

              // --- HARGA PRODUK (Read-Only) ---
              const Text(
                "Harga Produk",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              IgnorePointer(
                child: CustomTextfield(
                  controller: _priceController,
                  hintText: "",
                ),
              ),
              const SizedBox(height: 20),

              // --- DESKRIPSI PRODUK (Read-Only) ---
              const Text(
                "Deskripsi Produk",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              IgnorePointer(
                child: CustomTextfield(
                  controller: _descriptionController,
                  hintText: "",
                  maxLines: 5, // Biar kotaknya agak besar buat baca deskripsi
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Arahkan ke Halaman Edit sambil bawa data produk
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProductAdmin(
                              productData: widget.productData,
                            ),
                          ),
                        );

                        if (result == true) {
                          if (!context.mounted) return;
                          Navigator.pop(context, true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor:
                            AppColors.button, // Warna kapsul abu-abu lu
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showDeleteConfirmation();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Hapus",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ), // Jarak aman paling bawah sebelum mentok layar
            ],
          ),
        ),
      ),
    );
  }
}
