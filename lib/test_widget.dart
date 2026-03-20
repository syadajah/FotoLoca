import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fotoloca/widget/currency_format.dart';
import 'package:fotoloca/widget/custom_button.dart';
// Pastikan path import ini sesuai dengan lokasi file CustomTextField milikmu
import 'package:fotoloca/widget/custom_textfield.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:iconify_flutter/icons/heroicons.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final TextEditingController _tanggalController = TextEditingController();

  //Function untuk kalender

  Future<void> _pilihTanggal() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (pickedDate != null) {
      // Jika user memilih tanggal (tidak klik cancel)
      setState(() {
        // Format tanggalnya jadi string (Misal: 2026-03-18)
        // Kalau mau formatnya lebih bagus (misal: 18 Maret 2026), bisa pakai package 'intl'
        _tanggalController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Preview Custom TextField'),
        backgroundColor: const Color(0xFF8A8A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Mode Default (Tanpa Ikon)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const CustomTextfield(hintText: 'Masukkan Nama Produk'),
            const SizedBox(height: 24),

            const Text(
              '2. Mode Default (Suffix Icon)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const CustomTextfield(
              hintText: 'Masukkan Nama Kategori',
              icon: Icons.category,
              suffixIcon: Icon(Icons.check, color: Color(0xFF000000)),
            ),
            const SizedBox(height: 24),

            const Text(
              '3. Mode Default (Obscure Text)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const CustomTextfield(
              hintText: 'Masukkan Nama Kategori',
              icon: Icons.category,
              isObscure: true,
            ),
            const SizedBox(height: 24),

            const Text(
              '4. Mode Login (Dengan Ikon)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const CustomTextfield(hintText: 'Username', icon: Icons.person),
            const SizedBox(height: 24),

            const Text(
              '5. Mode Password (Obscure text)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const CustomTextfield(
              hintText: 'Password',
              icon: Icons.lock,
              isObscure: true,
            ),
            const SizedBox(height: 24),

            const Text(
              '6. Mode Angka (Khusus Harga/No HP)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const CustomTextfield(
              hintText: 'Masukkan Harga Sewa',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),
            const Text(
              '7. Mode Tanggal (Dengan Kalender)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextfield(
              hintText: 'Pilih tanggal',
              controller: _tanggalController,
              readOnly: true,
              onTap: _pilihTanggal,
              suffixIcon: Icon(Icons.calendar_month, color: Color(0xFF8A8A8A)),
            ),

            const SizedBox(height: 24),
            const Text(
              '8. Input harga dengan format Rupiah (Dengan Formatter)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextfield(
              hintText: 'Rp. ---.---',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyFormat(),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              '9. Button',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // CustomButton(
            //   text: "Tambah produk baru",
            //   hasStroke: true,
            //   icon: const Iconify(Mdi.plus, color: AppColors.button, size: 20),
            //   textColor: Colors.grey,
            //   backgroundColor: AppColors.background,
            //   onPressed: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (BuildContext context) => const TestScreen(),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
