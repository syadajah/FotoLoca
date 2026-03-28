import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fotoloca/services/product_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/custom_dropdown.dart';
import 'package:fotoloca/widget/custom_textfield.dart';
import 'package:fotoloca/widget/currency_format.dart';
import 'package:fotoloca/widget/custom_image_picker.dart';
import 'package:fotoloca/core/network/api_client.dart';

class CreateProductAdmin extends StatefulWidget {
  const CreateProductAdmin({super.key});

  @override
  State<CreateProductAdmin> createState() => _CreateProductAdminState();
}

class _CreateProductAdminState extends State<CreateProductAdmin> {
  // --- VARIABEL STATE ---
  File? _selectedImage;
  bool _isLoadingSubmit = false; // Loading saat klik tombol simpan

  // Controllers untuk input teks
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final List<String> _tierList = ['Essential', 'Signature', 'Exclusive'];

  // Variabel Kategori
  List<dynamic> _kategoriList = [];
  bool _isLoadingKategori = true; // Loading dropdown saat awal buka halaman
  int? _selectedKategoriId; // ID yang akan dikirim ke Laravel
  String? _selectedTier;

  @override
  void initState() {
    super.initState();
    _fetchKategori(); // Tarik data kategori saat halaman pertama kali dibuka
  }

  @override
  void dispose() {
    // Bersihkan memori saat halaman ditutup
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // --- FUNGSI AMBIL KATEGORI DARI LARAVEL ---
  Future<void> _fetchKategori() async {
    try {
      // 1. GANTI DIO POLOSAN MENJADI API CLIENT MILIKMU
      final response = await ApiClient().dio.get('/categories');

      setState(() {
        // Data dari Laravel sudah berbentuk array di dalam key 'data'
        _kategoriList = response.data['data'] ?? response.data;
        _isLoadingKategori = false;
      });
    } catch (e) {
      print("Gagal mengambil kategori: $e");
      setState(() => _isLoadingKategori = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat daftar kategori')),
        );
      }
    }
  }

  // --- FUNGSI BUKA GALERI ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // --- FUNGSI SAKTI: SIMPAN PRODUK ---
  Future<void> _simpanProduk() async {
    // 1. Validasi Input
    if (_namaController.text.isEmpty ||
        _hargaController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _selectedKategoriId == null ||
        _selectedTier == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data dan foto!')),
      );
      return;
    }

    setState(() => _isLoadingSubmit = true);

    try {
      // 2. Upload Gambar ke Supabase
      final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = 'uploads/$fileName';

      await Supabase.instance.client.storage
          .from('product-images')
          .upload(
            imagePath,
            _selectedImage!,
          ); // _selectedImage adalah file dari HP
      // 2. Minta URL publiknya dari Supabase
      final String imageUrl = Supabase.instance.client.storage
          .from('product-images')
          .getPublicUrl(imagePath);

      // 3. Bersihkan Format Harga (Hapus 'Rp' dan titik)
      final String rawHarga = _hargaController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      // 4. Kirim Data ke Laravel menggunakan ProductServices
      final response = await ProductServices().addProducts(
        idKategori: _selectedKategoriId.toString(),
        namaProduk: _namaController.text,
        hargaProduk: rawHarga,
        deskripsi: _deskripsiController.text,
        tierLevel: _selectedTier!,
        fotoUrl:
            imageUrl, // <--- Ini isinya misal: "https://xxx.supabase.co/storage/v1/object/public/product-images/uploads/product_123.jpg"
      );

      // 5. Tangani Hasil (Sukses / Gagal)
      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response['message'])));
          Navigator.pop(context, true); // Kembali ke list admin
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingSubmit = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, // Samakan dengan background
        elevation: 0, // Hilangkan bayangan/garis bawah
        scrolledUnderElevation: 0, // Mencegah perubahan warna saat di-scroll
        // 1. Tombol Back
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        // 2. Judul Halaman
        title: const Text(
          "Buat Produk",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0, // Agar judul tidak terlalu jauh dari tombol back
        // 3. Tombol Simpan (Kanan Atas)
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 24.0,
              top: 10.0,
              bottom: 10.0,
            ),
            child: ElevatedButton(
              onPressed: _isLoadingSubmit ? null : _simpanProduk,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF7A7A7A,
                ), // Warna abu-abu sesuai gambarmu
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // Membuatnya berbentuk kapsul (pill)
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isLoadingSubmit
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Simpan",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- NAMA PRODUK ---
              const Text(
                "Nama Produk",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: "Masukkan nama produk",
                controller: _namaController,
              ),
              const SizedBox(height: 15),

              // --- KATEGORI (DROPDOWN DINAMIS) ---
              const Text(
                "Kategori",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              _isLoadingKategori
                  ? const CircularProgressIndicator() // Tampilkan animasi muter jika data belum siap
                  : CustomDropdown(
                      hintText: "Pilih Kategori",
                      items: _kategoriList
                          .map<String>(
                            (item) => item['nama_kategori'].toString(),
                          )
                          .toList(),
                      onChanged: (value) {
                        final selectedItem = _kategoriList.firstWhere(
                          (item) => item['nama_kategori'] == value,
                        );
                        setState(() {
                          _selectedKategoriId = selectedItem['id'];
                        });
                      },
                    ),
              const SizedBox(height: 15),
              // --- TIER PAKET (BARU DITAMBAHKAN) ---
              const Text(
                "Tier Paket",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              // Pake container dropdown bawaan lu yang udah estetik
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF7A7A7A,
                  ).withOpacity(0.1), // Sesuai tema fotoloca
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTier,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF7A7A7A),
                    ),
                    items: _tierList.map((String tier) {
                      return DropdownMenuItem<String>(
                        value: tier,
                        child: Text(tier),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTier = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // --- HARGA ---
              const Text(
                "Harga",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: 'Rp. ---.---',
                controller: _hargaController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyFormat(),
                ],
              ),
              const SizedBox(height: 15),

              // --- DESKRIPSI ---
              const Text(
                "Deskripsi",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: "Masukkan deskripsi",
                controller: _deskripsiController,
                maxLines: 5,
              ),
              const SizedBox(height: 15),

              // --- FOTO PRODUK ---
              const Text(
                "Foto Product",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomImagePicker(onTap: _pickImage, imageFile: _selectedImage),
            ],
          ),
        ),
      ),
    );
  }
}
