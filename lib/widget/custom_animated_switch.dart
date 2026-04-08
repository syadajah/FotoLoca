import 'package:flutter/material.dart';

class CustomAnimatedSwitch extends StatelessWidget {
  final bool value; // Status nyala/mati
  final ValueChanged<bool> onChanged; // Fungsi pas diklik
  final bool isLoading; // Tambahan biar kalo loading dia muter

  const CustomAnimatedSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Kalau lagi loading, switch-nya gak bisa diklik
      onTap: isLoading ? null : () => onChanged(!value),

      // --- BACKGROUND SAKLAR (Berubah warna halus) ---
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // Kecepatan animasi
        curve: Curves.easeInOut, // Gaya animasi ngaret
        width: 56, // Lebar saklar
        height: 30, // Tinggi saklar
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Kalau nyala hijau, mati abu-abu (atau merah terserah lu)
          color: value ? const Color(0xFF2E7D32) : Colors.grey.shade300,
        ),

        // --- LINGKARAN PUTIH YANG GESER KANAN KIRI ---
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          // INI MAGIC-NYA: Geser otomatis dari kiri ke kanan
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(3.0), // Jarak lingkaran ke pinggir
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Lingkaran putih
              ),
              // Tambahin indikator muter kalo lagi loading API
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
