import 'dart:io'; // Untuk File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Library ambil foto
import 'package:supabase_flutter/supabase_flutter.dart'; // Library Supabase
import 'package:uuid/uuid.dart'; // Library bikin nama file unik
import 'package:fotoloca/services/product_services.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/custom_button.dart';
import 'package:fotoloca/widget/custom_textfield.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

class EditProductAdmin extends StatefulWidget {
  final Map<String, dynamic> productData;

  const EditProductAdmin({super.key, required this.productData});

  @override
  State<EditProductAdmin> createState() => _EditProductAdminState();
}

class _EditProductAdminState extends State<EditProductAdmin> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  final List<String> _tierList = ['Essential', 'Signature', 'Exclusive'];

  int? _selectedCategoryId;
  String? _currentImageUrl; // URL lama dari database
  File? _imageFile; // File foto baru kalau user ganti
  bool _isSubmitting = false;
  String? _selectedTier;

  // Inisialisasi Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.productData['nama_produk'],
    );
    _priceController = TextEditingController(
      text: widget.productData['harga_produk'].toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.productData['deskripsi'],
    );

    _currentImageUrl = widget.productData['foto']; // Link foto lama
    _selectedCategoryId = widget.productData['id_kategori'];
    _selectedTier = widget.productData['tier_level'] ?? 'Essential';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- FUNGSI AMBIL FOTO DARI GALERI ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Simpan file lokalnya
        _currentImageUrl =
            null; // Hapus URL lama dari view biar nampilin foto baru
      });
    }
  }

  // --- 1. POP-UP KONFIRMASI (VERSI SUPER AMAN) ---
  void _showSaveConfirmationDialog() {
    // Validasi dasar
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama, Harga, dan Kategori wajib diisi!")),
      );
      return;
    }

    // Tampilkan dialog, lalu tunggu jawabannya (.then)
    showDialog<bool>(
      context: context,
      builder: (context) {
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
                  Icons.help_outline,
                  color: AppColors.button,
                  size: 50,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Update Produk?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Apakah kamu yakin ingin menyimpan perubahan pada produk ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tombol Batal: Tutup pop-up dan bawa nilai 'false'
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
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
                    // Tombol Lanjutkan: Tutup pop-up dan bawa nilai 'true'
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.button,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Simpan"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((isConfirmed) {
      // Cek kalau user ngeklik "Simpan" (isConfirmed == true)
      if (isConfirmed == true) {
        _prosesUpdateProduk(); // Jalankan proses upload-nya di layar utama!
      }
    });
  }

  // --- 2. LOGIKA UTAMA (UDAH GAK PAKE CONTEXT LUAR LAGI) ---
  Future<void> _prosesUpdateProduk() async {
    setState(
      () => _isSubmitting = true,
    ); // Nyalakan efek loading "Menyimpan..." di tombol luar

    String? newFotoUrl;

    try {
      if (_imageFile != null) {
        // 1. Bikin nama file unik
        final fileName = '${const Uuid().v4()}.jpg';

        // 2. Gabungin nama folder "uploads/" sama nama filenya (Sesuai SS lu)
        final fullPath = 'uploads/$fileName';

        // 3. Tembak ke bucket yang bener: 'product-images'
        await _supabase.storage
            .from('product-images')
            .upload(
              fullPath,
              _imageFile!,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        // 4. Ambil URL publiknya dari bucket dan path yang bener
        newFotoUrl = _supabase.storage
            .from('product-images')
            .getPublicUrl(fullPath);
      }

      final result = await ProductServices().updateProducts(
        id: widget.productData['id'],
        idKategori: _selectedCategoryId.toString(),
        namaProduk: _nameController.text,
        hargaProduk: _priceController.text,
        deskripsi: _descriptionController.text,
        tierLevel: _selectedTier!,
        fotoUrl: newFotoUrl,
      );

      setState(() => _isSubmitting = false); // Matikan loading

      if (!mounted) return;

      if (result['success']) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false); // Matikan loading kalau error
      print(
        "Error update: $e",
      ); // Bakal nongol di terminal kalau bucket masih salah
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Edit Produk", style: TextStyle(color: Colors.black)),
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
              // --- KOTAK GAMBAR (SAMA KAYAK CREATE, BISA DIKLIK) ---
              Center(
                child: GestureDetector(
                  onTap: _pickImage, // Klik buat ganti foto
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    // Logika Preview Foto
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ) // Nampilin foto baru
                          : _currentImageUrl != null
                          ? Image.network(
                              _currentImageUrl!,
                              fit: BoxFit.cover,
                            ) // Nampilin foto lama
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Iconify(
                                  Mdi.camera,
                                  color: AppColors.button,
                                  size: 40,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Ganti Foto Produk",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- FORM INPUT ---
              const Text(
                "Nama Produk",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              CustomTextfield(
                controller: _nameController,
                hintText: "Masukkan nama produk",
              ),
              const SizedBox(height: 20),

              const Text(
                "Kategori Produk",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<dynamic>>(
                future: ProductServices().getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator(
                      color: AppColors.button,
                    );
                  }
                  final categories = snapshot.data ?? [];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A7A7A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedCategoryId,
                        hint: const Text(
                          "Pilih Kategori",
                          style: TextStyle(color: Colors.grey),
                        ),
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.button,
                        ),
                        items: categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat['id'],
                            child: Text(cat['nama_kategori']),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCategoryId = value),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // --- DROPDOWN TIER PAKET BARU ---
              const Text(
                "Tier Paket",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A7A7A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTier,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.star_border_rounded,
                      color: AppColors.button,
                    ),
                    items: _tierList.map((tier) {
                      return DropdownMenuItem<String>(
                        value: tier,
                        child: Text(
                          tier,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedTier = value),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Harga Produk",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              CustomTextfield(
                controller: _priceController,
                hintText: "Contoh: 50000",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              const Text(
                "Deskripsi Produk",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              CustomTextfield(
                controller: _descriptionController,
                hintText: "Deskripsi",
                maxLines: 5,
              ),
              const SizedBox(height: 30),

              // --- TOMBOL SIMPAN (PANGGIL POP-UP DULU) ---
              CustomButton(
                text: _isSubmitting ? "Menyimpan..." : "Simpan Perubahan",
                backgroundColor: AppColors.button,
                textColor: Colors.white,
                // Panggil Dialog Konfirmasi Ngabss!
                onPressed: _isSubmitting ? () {} : _showSaveConfirmationDialog,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
