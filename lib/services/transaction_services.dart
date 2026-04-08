import 'package:dio/dio.dart';
import 'package:fotoloca/core/network/api_client.dart';

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
      // Ngetok pintu Laravel cuma 1 kali!
      final response = await _apiClient.dio.get('/transaction-setup/$idProduk');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data['data'];

        // 1. Olah Data Tanggal (Ubah String YYYY-MM-DD jadi DateTime Flutter)
        List<dynamic> rawDates = responseData['booked_dates'] ?? [];
        List<DateTime> parsedDates = [];
        for (var dateStr in rawDates) {
          try {
            parsedDates.add(DateTime.parse(dateStr.toString()));
          } catch (e) {
            print("⚠️ Gagal parsing tanggal: $dateStr");
          }
        }

        // 2. Olah Data Add-ons
        List<dynamic> addonsList = responseData['addons'] ?? [];

        print("✅ Fetch data add ons & jadwal sukses!");

        // 3. Kembalikan 2 data sekaligus dalam 1 Map
        return {
          'success': true,
          'booked_dates': parsedDates,
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
}
