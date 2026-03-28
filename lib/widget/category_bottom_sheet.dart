import 'package:flutter/material.dart';
import 'package:fotoloca/services/category_services.dart';
import 'package:shimmer/shimmer.dart';

class CategoryBottomSheet extends StatefulWidget {
  final List<int> selectedCategoryIds;
  final Function(List<int>) onSelectionChanged;

  const CategoryBottomSheet({
    super.key,
    required this.selectedCategoryIds,
    required this.onSelectionChanged,
  });

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  // 2. Panggil class service-nya ke sini
  final CategoryServices _categoryServices = CategoryServices();

  List<Map<String, dynamic>> _kategoriList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  // 3. Fungsi fetch-nya jadi super bersih!
  Future<void> _fetchKategori() async {
    setState(() => _isLoading = true);
    try {
      // Tinggal panggil getCategories dari service
      final List<dynamic> dataApi = await _categoryServices.getCategories();

      setState(() {
        _kategoriList = dataApi.map((item) {
          return {
            "id": item['id'],
            "nama": item['nama_kategori'],
            "isChecked": widget.selectedCategoryIds.contains(item['id']),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // --- FUNGSI MUNCULIN POP-UP TAMBAH/EDIT ---
  void _showFormKategoriDialog({String? initialName, int? idKategori}) {
    final TextEditingController textController = TextEditingController(
      text: initialName,
    );
    final bool isEdit = initialName != null;

    showDialog(
      context: context,
      barrierDismissible:
          false, // Biar user gak bisa tutup pop-up sembarangan pas lagi loading
      builder: (context) {
        bool isSubmitting = false; // Variabel loading khusus untuk pop-up

        // Gunakan StatefulBuilder agar bisa update UI di dalam Dialog
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFFF9F9F9),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? "Edit kategori" : "Tambah kategori",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // --- TEXTFIELD ---
                      TextField(
                        controller: textController,
                        enabled:
                            !isSubmitting, // Kunci textfield pas lagi loading
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.local_offer,
                            color: Colors.grey,
                            size: 20,
                          ),
                          hintText: "Nama kategori",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- TOMBOL BATAL & LANJUTKAN ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                            child: const Text(
                              "Batal",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 10),

                          ElevatedButton(
                            // Jika loading, matikan tombol (null)
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    final namaKategori = textController.text
                                        .trim();

                                    // Validasi kosong
                                    if (namaKategori.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Nama kategori tidak boleh kosong!',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    // Nyalakan animasi muter di tombol
                                    setStateDialog(() => isSubmitting = true);

                                    Map<String, dynamic> result;

                                    // Cek ini mode EDIT atau TAMBAH
                                    if (isEdit && idKategori != null) {
                                      result = await _categoryServices
                                          .updateCategory(
                                            idKategori,
                                            namaKategori,
                                          );
                                    } else {
                                      result = await _categoryServices
                                          .addCategory(namaKategori);
                                    }

                                    // Matikan animasi muter
                                    setStateDialog(() => isSubmitting = false);

                                    if (!context.mounted) return;

                                    if (result['success']) {
                                      Navigator.pop(context); // Tutup pop-up
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(result['message']),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      // REFRESH DATA BOTTOM SHEET BIAR LANGSUNG MUNCUL!
                                      _fetchKategori();
                                    } else {
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
                              backgroundColor: const Color(0xFF5A5A5A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Lanjutkan"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(int idKategori, String namaKategori) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFFF9F9F9),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
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
                        "Hapus Kategori?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Apakah kamu yakin ingin menghapus kategori "$namaKategori"?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Tombol Batal
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isDeleting
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
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

                          // Tombol Hapus
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isDeleting
                                  ? null
                                  : () async {
                                      setStateDialog(() => isDeleting = true);

                                      // Panggil fungsi API Hapus dari ProductServices
                                      final result = await _categoryServices
                                          .deleteCategory(idKategori);

                                      setStateDialog(() => isDeleting = false);

                                      if (!context.mounted) return;
                                      Navigator.pop(
                                        context,
                                      ); // Tutup pop-up konfirmasi

                                      if (result['success']) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(result['message']),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        // REFRESH DATA BOTTOM SHEET!
                                        _fetchKategori();
                                      } else {
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
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
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
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: () => _showFormKategoriDialog(),
            child: const Row(
              children: [
                Icon(Icons.add, color: Colors.black54, size: 20),
                SizedBox(width: 10),
                Text(
                  "Tambah kategori baru",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    itemBuilder: (context, index) => const SkeletonCategory(),
                    itemCount: 5,
                  )
                : _kategoriList.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada kategori",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _kategoriList.length,
                    itemBuilder: (context, index) {
                      final kategori = _kategoriList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_offer,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                kategori['nama'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: kategori['isChecked'],
                                activeColor: const Color(0xFF5A5A5A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.5,
                                ),
                                onChanged: (bool? value) {
                                  setState(() {
                                    _kategoriList[index]['isChecked'] = value!;
                                  });

                                  final selectedIds = _kategoriList
                                      .where((k) => k['isChecked'] == true)
                                      .map((k) => k['id'] as int)
                                      .toList();

                                  widget.onSelectionChanged(selectedIds);
                                },
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showFormKategoriDialog(
                                    initialName: kategori['nama'],
                                    idKategori: kategori['id'],
                                  );
                                } else if (value == 'delete') {
                                  _showDeleteConfirmation(
                                    kategori['id'],
                                    kategori['nama'],
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class SkeletonCategory extends StatelessWidget {
  const SkeletonCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Jarak antar item
        child: Row(
          children: [
            // Fake Icon Kiri
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 15),

            // Fake Teks Kategori (Pakai Expanded biar aman di dalam Row)
            Expanded(
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Fake Checkbox / Icon Kanan
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
