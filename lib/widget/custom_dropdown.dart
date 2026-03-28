import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String hintText;
  final String? value; // Nilai yang sedang dipilih
  final List<String> items; // Daftar pilihan kategori
  final ValueChanged<String?> onChanged; // Fungsi saat pilihan diubah

  const CustomDropdown({
    super.key,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF7A7A7A)),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF4F4F4), // Sama dengan CustomTextfield
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 12.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF8A8A8A), width: 1.5),
        ),
      ),
      
      // Mengubah list String menjadi list menu dropdown
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      
      onChanged: onChanged,
    );
  }
}