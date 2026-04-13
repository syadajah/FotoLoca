import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fotoloca/services/transaction_services.dart';
import 'package:fotoloca/screen/kasir/invoice_screen.dart';

class TransactionBottomSheet extends StatefulWidget {
  final Map<String, dynamic> productData;
  final String categoryName;

  const TransactionBottomSheet({
    super.key,
    required this.productData,
    required this.categoryName,
  });

  @override
  State<TransactionBottomSheet> createState() => _TransactionBottomSheetState();
}

class _TransactionBottomSheetState extends State<TransactionBottomSheet> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _uangBayarController = TextEditingController();

  List<DateTime> _bookedDates = [];
  List<dynamic> _availableAddOns = [];
  final List<int> _selectedAddOnIds = [];

  DateTime? _selectedDate;
  String _kodeUnik = '';
  int _uangBayar = 0;

  bool _isAgreed = false;
  bool _isSubmitting = false;
  bool _isLoadingSetup = true; // Cuma 1 loading buat semuanya!

  @override
  void initState() {
    super.initState();
    _generateKodeUnik();
    _fetchSetupData(); // Tarik semua data (Tgl laku & Add-ons) 1 kali jalan
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _uangBayarController.dispose();
    super.dispose();
  }

  // --- API CALLS ---
  Future<void> _fetchSetupData() async {
    setState(() => _isLoadingSetup = true);

    final service = TransactionServices();
    final result = await service.getTransactionSetup(widget.productData['id']);

    if (mounted) {
      if (result['success'] == true) {
        setState(() {
          // 👇 UBAH DISINI: Langsung ambil nilainya dari result, tanpa menyisipkan ['data']
          // Gunakan List<DateTime>.from() untuk memastikan tipe datanya solid
          _bookedDates = List<DateTime>.from(result['booked_dates'] ?? []);
          _availableAddOns = result['addons'] ?? [];
          _isLoadingSetup = false;
        });
      } else {
        setState(() => _isLoadingSetup = false);
      }
    }
  }

  void _generateKodeUnik() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    String randomStr = String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    setState(() => _kodeUnik = 'FL-$randomStr');
  }

  // --- LOGIKA KALENDER ---
  bool _isDateBooked(DateTime day) {
    return _bookedDates.any(
      (booked) =>
          day.year == booked.year &&
          day.month == booked.month &&
          day.day == booked.day,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    DateTime safeInitialDate = _selectedDate ?? today;
    while (_isDateBooked(safeInitialDate)) {
      safeInitialDate = safeInitialDate.add(const Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: today,
      lastDate: DateTime(2030),
      selectableDayPredicate: (DateTime day) => !_isDateBooked(day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5A5A5A),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // --- LOGIKA HARGA & FORMAT ---
  int get _grandTotal {
    int basePrice =
        int.tryParse(widget.productData['harga_produk'].toString()) ?? 0;
    int addOnPrice = 0;
    for (var addon in _availableAddOns) {
      if (_selectedAddOnIds.contains(addon['id'])) {
        addOnPrice += int.tryParse(addon['harga_addon'].toString()) ?? 0;
      }
    }
    return basePrice + addOnPrice;
  }

  String formatRupiah(int number) {
    String numStr = number.toString();
    String result = '';
    int count = 0;
    for (int i = numStr.length - 1; i >= 0; i--) {
      result = numStr[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) result = '.$result';
    }
    return 'Rp $result';
  }

  void _onUangBayarChanged(String value) {
    String numericOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) {
      setState(() => _uangBayar = 0);
      _uangBayarController.clear();
      return;
    }

    int val = int.parse(numericOnly);
    setState(() => _uangBayar = val);

    String result = '';
    int count = 0;
    for (int i = numericOnly.length - 1; i >= 0; i--) {
      result = numericOnly[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) result = '.$result';
    }

    _uangBayarController.value = TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  // --- POPUPS TRANSAKSI ---
  void _showErrorBookingDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text(
                'Gagal Booking',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(errorMessage, style: const TextStyle(fontSize: 14)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A5A5A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _fetchSetupData(); // Tarik data ulang
                setState(() => _selectedDate = null);
              },
              child: const Text(
                'Mengerti',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(Map<String, dynamic> responseData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 15),
              const Text(
                'Transaksi Berhasil!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pesanan telah tersimpan di sistem.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvoiceScreenKasir(
                          productData: widget.productData,
                          transactionData: responseData['data'],
                          categoryName: widget.categoryName,
                        ),
                      ),
                      (Route<dynamic> route) => route.isFirst,
                    );
                  },
                  child: const Text(
                    'Lihat Invoice',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Konfirmasi Pesanan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah kamu yakin data pesanan dan pembayaran sudah benar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A5A5A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (_namaController.text.isEmpty ||
                          _uangBayar == 0 ||
                          _selectedDate == null) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Harap lengkapi semua data!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final emailInput = _emailController.text;
                      if (emailInput.isNotEmpty) {
                        final bool emailValid = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        ).hasMatch(emailInput);
                        if (!emailValid) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Format email tidak valid!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      setState(() => _isSubmitting = true);
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );

                      final String formattedDate =
                          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

                      final response = await TransactionServices()
                          .createTransaction(
                            idProduk: widget.productData['id'],
                            namaPelanggan: _namaController.text,
                            emailPelanggan: _emailController.text,
                            jadwal: formattedDate,
                            uangBayar: _uangBayar,
                            nomorUnik: _kodeUnik,
                            addons: _selectedAddOnIds,
                          );

                      if (!context.mounted) return;

                      setState(() => _isSubmitting = false);
                      Navigator.pop(context);
                      Navigator.pop(context);

                      if (response['success'] == true) {
                        _showSuccessDialog(response);
                      } else {
                        _showErrorBookingDialog(
                          response['message'] ?? 'Terjadi kesalahan sistem.',
                        );
                      }
                    },
              child: const Text('Yakin', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- WIDGET RENDER ---
  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.productData['foto'] ?? '';
    final String namaProduk =
        widget.productData['nama_produk'] ?? 'Nama Produk';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Transaksi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Card Produk
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 80,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 80,
                              height: 60,
                              color: Colors.grey.shade200,
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 60,
                            color: Colors.grey.shade200,
                          ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          namaProduk,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel("Nama Pelanggan"),
            _buildTextField(_namaController, "Masukkan nama pelanggan"),

            _buildLabel("Email Pelanggan"),
            _buildTextField(
              _emailController,
              "Masukkan email aktif",
              keyboardType: TextInputType.emailAddress,
            ),

            _buildLabel("Jadwal Acara"),

            // JIKA MASIH LOADING DARI DATABASE (PAKAI _isLoadingSetup)
            _isLoadingSetup
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF5A5A5A),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Mengecek jadwal kosong...",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? "Pilih jadwal acara"
                                : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                            style: TextStyle(
                              color: _selectedDate == null
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 15),

            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Layanan Tambahan (Opsional)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // TAMPILAN ADD ON (PAKAI _isLoadingSetup)
            _isLoadingSetup
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _availableAddOns.isEmpty
                ? const Text(
                    "Tidak ada layanan tambahan",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  )
                : Column(
                    children: _availableAddOns.map((addon) {
                      bool isChecked = _selectedAddOnIds.contains(addon['id']);
                      int price =
                          int.tryParse(addon['harga_addon'].toString()) ?? 0;
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: const Color(0xFF5A5A5A),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          addon['nama_addon'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          "+ ${formatRupiah(price)}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedAddOnIds.add(addon['id']);
                            } else {
                              _selectedAddOnIds.remove(addon['id']);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

            const Divider(),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Tagihan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  formatRupiah(_grandTotal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            _buildLabel("Uang Bayar"),
            _buildUangBayarField(),

            const SizedBox(height: 15),
            _buildLabel("Kode Unik"),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: _kodeUnik,
                hintStyle: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _isAgreed,
                    activeColor: const Color(0xFF5A5A5A),
                    onChanged: (val) =>
                        setState(() => _isAgreed = val ?? false),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Cek kembali pilihan pelanggan dengan Baik dan Benar untuk menyetujui Paket Jasa Fotografi yang dipilih.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_uangBayar < _grandTotal) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Uang bayar masih kurang!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (!_isAgreed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Harap centang kotak persetujuan di atas!',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  _showConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: (_isAgreed && _uangBayar >= _grandTotal)
                      ? const Color(0xFF5A5A5A)
                      : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Bayar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatRupiah(_grandTotal),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUangBayarField() {
    bool isKosong = _uangBayar == 0;
    bool isCukup = _uangBayar >= _grandTotal;

    Color borderColor = isKosong
        ? Colors.grey.shade300
        : (isCukup ? Colors.green : Colors.red);
    Color focusColor = isKosong ? const Color(0xFF5A5A5A) : borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _uangBayarController,
          keyboardType: TextInputType.number,
          onChanged: _onUangBayarChanged,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isKosong
                ? Colors.black
                : (isCukup ? Colors.green.shade700 : Colors.red),
          ),
          decoration: InputDecoration(
            prefixText: "Rp ",
            prefixStyle: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            hintText: "0",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: isKosong
                ? const Color(0xFFF5F5F5)
                : (isCukup ? Colors.green.shade50 : Colors.red.shade50),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: focusColor, width: 2),
            ),
            suffixIcon: isKosong
                ? null
                : Icon(
                    isCukup ? Icons.check_circle : Icons.error,
                    color: isCukup ? Colors.green : Colors.red,
                  ),
          ),
        ),
        if (!isKosong)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              isCukup
                  ? "Uang pas / lebih (Kembalian: ${formatRupiah(_uangBayar - _grandTotal)})"
                  : "Uang masih kurang!",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCukup ? Colors.green : Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 15.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5A5A5A)),
        ),
      ),
    );
  }
}
