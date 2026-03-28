import 'dart:io';
import 'dart:ui'; // Wajib di-import untuk menghitung metrik garis (PathMetric)
import 'package:flutter/material.dart';

class CustomImagePicker extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;

  const CustomImagePicker({super.key, required this.onTap, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        // <-- Kita ganti DottedBorder menjadi CustomPaint
        painter: DashedRectPainter(
          color: const Color(0xFFAAAAAA), // Warna garis abu-abu
          strokeWidth: 1.5, // Ketebalan garis
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            height: 180,
            color: const Color(0xFFF9F9F9),
            child: imageFile != null
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      "Pilih gambar",
                      style: TextStyle(
                        color: Color(0xFF7A7A7A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// --- MESIN PEMBUAT GARIS PUTUS-PUTUS (TANPA PACKAGE) ---
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedRectPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // 1. Buat bentuk kotak dengan sudut melengkung 15
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(15),
    );

    // 2. Siapkan jalur garisnya
    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = Path();

    const double dashWidth = 8.0; // Panjang coretan garis
    const double dashSpace = 4.0; // Jarak kosong antar garis
    double distance = 0.0;

    // 3. Potong-potong garis solid menjadi putus-putus
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0; // Reset untuk sisi/sudut selanjutnya
    }

    // 4. Gambar ke layar!
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
