import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fotoloca/services/product_services.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/currency_format.dart';
import 'package:shimmer/shimmer.dart';

class AddonBottomSheet extends StatefulWidget {
  const AddonBottomSheet({super.key});

  @override
  State<AddonBottomSheet> createState() => _AddonBottomSheetState();
}

class _AddonBottomSheetState extends State<AddonBottomSheet> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  List<dynamic> _addonList = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchAddOns();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  // Tarik data Add-ons
  Future<void> _fetchAddOns() async {
    setState(() => _isLoading = true);
    final data = await ProductServices().getAddOns();
    setState(() {
      _addonList = data;
      _isLoading = false;
    });
  }

  // Tambah Add-ons
  Future<void> _simpanAddOn() async {
    if (_namaController.text.isEmpty || _hargaController.text.isEmpty) return;

    setState(() => _isSubmitting = true);
    final rawHarga = _hargaController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final result = await ProductServices().addAddOn(
      _namaController.text,
      rawHarga,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    if (result['success']) {
      _namaController.clear();
      _hargaController.clear();
      _fetchAddOns(); // Refresh list setelah sukses nambah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil ditambah!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  // Hapus Add-ons
  Future<void> _hapusAddOn(int id) async {
    final result = await ProductServices().deleteAddOn(id);
    if (result['success']) {
      _fetchAddOns();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            20, // Biar gak ketutup keyboard
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Garis tengah estetik
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Kelola Add-ons",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // Form Tambah Add-on
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    hintText: "Nama Add-on",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _hargaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyFormat(),
                  ],
                  decoration: InputDecoration(
                    hintText: "Harga",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: AppColors.button,
                radius: 22,
                child: IconButton(
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add, color: Colors.white),
                  onPressed: _isSubmitting ? null : _simpanAddOn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),

          // List Add-ons
          _isLoading
              ? ListView.builder(
                  itemBuilder: (context, index) => const SkeletonAddon(),
                  itemCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                )
              : _addonList.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Belum ada Add-on"),
                  ),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _addonList.length,
                    itemBuilder: (context, index) {
                      final item = _addonList[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item['nama_addon'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Rp ${item['harga_addon']}',
                          style: const TextStyle(color: Color(0xFFD4AF37)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _hapusAddOn(item['id']),
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

class SkeletonAddon extends StatelessWidget {
  const SkeletonAddon({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Jarak antar item
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 300,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5,),
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
