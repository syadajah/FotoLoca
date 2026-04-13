import 'package:dio/dio.dart';
import 'package:fotoloca/core/network/api_client.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class TransactionServices {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> createTransaction({
    required int idProduk,
    required String namaPelanggan,
    required String emailPelanggan,
    required String jadwal,
    required int uangBayar,
    required String nomorUnik,
    List<int>?
    addons, // <-- TAMBAHAN: Menerima list ID Add-on (opsional bisa null)
  }) async {
    try {
      // Kita bungkus datanya ke Map dulu biar rapi
      Map<String, dynamic> dataPayload = {
        'id_produk': idProduk,
        'nama_pelanggan': namaPelanggan,
        'email_pelanggan': emailPelanggan,
        'jadwal': jadwal,
        'uang_bayar': uangBayar,
        'nomor_unik': nomorUnik,
      };

      // Kalau kasir milih add-on (list-nya gak kosong), baru kita masukin ke payload
      if (addons != null && addons.isNotEmpty) {
        dataPayload['addons'] = addons;
      }

      final response = await _apiClient.dio.post(
        '/transaction',
        data: dataPayload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Berhasil',
          'data': response
              .data['data'], // Ini yang tadi bikin error null, udah aman sekarang
        };
      }
      return {'success': false, 'message': 'Gagal melakukan transaksi'};
    } on DioException catch (e) {
      String errorMessage = 'Terjadi kesalahan pada server.';

      // TANGKAP PESAN ERROR DARI LARAVEL (Termasuk status 400)
      if (e.response != null && e.response?.data != null) {
        // Cek kalau ada 'message' dari JSON Laravel
        if (e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        }
        // Cek khusus validasi form 422 (Opsional)
        else if (e.response?.statusCode == 422 &&
            e.response?.data['errors'] != null) {
          final errors = e.response?.data['errors'];
          errorMessage = errors.values.first[0].toString();
        }
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem.'};
    }
  }

  // Fungsi untuk narik history transaksi dengan filter
  Future<List<dynamic>> getTransactions({
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (startDate != null && startDate.isNotEmpty)
        queryParams['start_date'] = startDate;
      if (endDate != null && endDate.isNotEmpty)
        queryParams['end_date'] = endDate;

      final response = await _apiClient.dio.get(
        '/transaction',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("Gagal mengambil history transaksi: $e");
      return [];
    }
  }

  // --- FUNGSI MENGAMBIL TANGGAL LAKU ---
  Future<List<DateTime>> getBookedDates(int idProduk) async {
    try {
      // UBAH BARIS INI: Pakai _apiClient yang udah lu deklarasi di atas class
      final response = await _apiClient.dio.get('/booked-dates/$idProduk');

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> rawDates = response.data['data'] ?? [];
        List<DateTime> parsedDates = [];

        // Ubah format string dari Laravel (YYYY-MM-DD) jadi DateTime Flutter
        for (var dateStr in rawDates) {
          try {
            parsedDates.add(DateTime.parse(dateStr.toString()));
          } catch (e) {
            print("⚠️ Gagal parsing tanggal: $dateStr");
          }
        }

        print("✅ SUKSES NARIK TANGGAL LAKU: $parsedDates");
        return parsedDates;
      }
      return [];
    } on DioException catch (e) {
      // Biar error-nya kelihatan jelas di terminal
      print(
        "❌ ERROR DIO TANGGAL: ${e.response?.statusCode} - ${e.response?.data}",
      );
      return [];
    } catch (e) {
      print("❌ ERROR API TANGGAL LAINNYA: $e");
      return [];
    }
  }

  // --- JURUS 1 KALI JALAN: NANGKEP TANGGAL LAKU & ADDON ---
  Future<Map<String, dynamic>> getTransactionSetup(int idProduk) async {
    try {
      final response = await _apiClient.dio.get('/transaction-setup/$idProduk');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data['data'];

        List<dynamic> rawDates = responseData['booked_dates'] ?? [];
        List<DateTime> parsedDates = [];
        for (var dateStr in rawDates) {
          try {
            // 👇 UBAH BARIS INI: Gunakan DateFormat agar cocok dengan "14 Apr 2026"
            parsedDates.add(
              DateFormat('dd MMM yyyy').parse(dateStr.toString()),
            );
          } catch (e) {
            print("⚠️ Gagal parsing tanggal di Service: $dateStr | Error: $e");
          }
        }

        List<dynamic> addonsList = responseData['addons'] ?? [];
        print("✅ Fetch data add ons & jadwal sukses!");

        return {
          'success': true,
          'booked_dates':
              parsedDates, // Ini sudah berupa List<DateTime> yang valid!
          'addons': addonsList,
        };
      }
      return {'success': false, 'message': 'Gagal merespon dari server'};
    } on DioException catch (e) {
      print("❌ ERROR DIO SETUP: ${e.response?.statusCode}");
      return {'success': false, 'message': 'Koneksi ke server bermasalah.'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> downloadLaporan({
    String? startDate,
    String? endDate,
    required String type, // 'excel' atau 'pdf'
  }) async {
    try {
      Map<String, dynamic> queryParams = {'type': type}; // Kirim type ke API
      if (startDate != null && startDate.isNotEmpty)
        queryParams['start_date'] = startDate;
      if (endDate != null && endDate.isNotEmpty)
        queryParams['end_date'] = endDate;

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Nentuin ekstensi file otomatis
      String extension = type == 'pdf' ? '.pdf' : '.xlsx';
      String fileName =
          "Laporan_${DateTime.now().millisecondsSinceEpoch}$extension";
      String savePath = "${directory!.path}/$fileName";

      await _apiClient.dio.download(
        '/transaction/export', // Pastikan endpoint lu ini
        savePath,
        queryParameters: queryParams,
      );

      final result = await OpenFilex.open(savePath);

      if (result.type == ResultType.done) {
        return {'success': true, 'message': 'Laporan berhasil dibuka.'};
      } else {
        return {
          'success': false,
          'message':
              'Laporan tersimpan di perangkat (Aplikasi pembaca tidak ditemukan).',
        };
      }
    } catch (e) {
      print("Gagal download: $e");
      return {'success': false, 'message': 'Gagal mengunduh laporan.'};
    }
  }

  // --- FUNGSI KIRIM INVOICE KE EMAIL ---
  Future<Map<String, dynamic>> sendInvoiceToEmail(int transactionId) async {
    try {
      final response = await _apiClient.dio.post(
        '/transaction/$transactionId/send-invoice',
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Email berhasil dikirim',
        };
      }
      return {'success': false, 'message': 'Gagal mengirim invoice'};
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Gagal mengirim email',
        };
      }
      return {'success': false, 'message': 'Koneksi ke server bermasalah.'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }
}
