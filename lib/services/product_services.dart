import 'package:dio/dio.dart';
import 'package:fotoloca/core/network/api_client.dart';

class ProductServices {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> addProducts({
    required String idKategori,
    required String namaProduk,
    required String hargaProduk,
    required String deskripsi,
    required String tierLevel,
    String? fotoUrl,
  }) async {
    try {
      Map<String, dynamic> dataPayload = {
        'id_kategori': idKategori,
        'nama_produk': namaProduk,
        'harga_produk': hargaProduk,
        'deskripsi': deskripsi,
        'tier_level': tierLevel,
      };

      if (fotoUrl != null) {
        dataPayload['foto'] = fotoUrl;
      }

      final response = await _apiClient.dio.post(
        '/products',
        data: dataPayload,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Produk berhasil ditambahkan.'};
      }
      return {'success': false, 'message': 'Gagal menyimpan produk.'};
    } on DioException catch (e) {
      // 👇 PENANGKAP ERROR 422
      if (e.response != null && e.response?.data != null) {
        if (e.response?.statusCode == 422 &&
            e.response?.data['errors'] != null) {
          final errors = e.response?.data['errors'];
          return {
            'success': false,
            'message': errors.values.first[0].toString(),
          };
        }
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Gagal menambah produk',
        };
      }
      return {'success': false, 'message': 'Koneksi ke server bermasalah'};
    }
  }

  Future<List<dynamic>> showProducts() async {
    try {
      final response = await _apiClient.dio.get('/products');
      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      return [];
    } catch (e) {
      print("Error show product: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> updateProducts({
    required int id,
    required String idKategori,
    required String namaProduk,
    required String hargaProduk,
    required String deskripsi,
    required String tierLevel,
    String? fotoUrl,
  }) async {
    try {
      Map<String, dynamic> dataPayload = {
        'id_kategori': idKategori,
        'nama_produk': namaProduk,
        'harga_produk': hargaProduk,
        'deskripsi': deskripsi,
        'tier_level': tierLevel,
      };

      if (fotoUrl != null) {
        dataPayload['foto'] = fotoUrl;
      }

      final response = await _apiClient.dio.put(
        '/products/$id',
        data: dataPayload,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Produk berhasil diupdate.'};
      }
      return {'success': false, 'message': 'Gagal mengupdate produk.'};
    } on DioException catch (e) {
      // 👇 PENANGKAP ERROR 422
      if (e.response != null && e.response?.data != null) {
        if (e.response?.statusCode == 422 &&
            e.response?.data['errors'] != null) {
          final errors = e.response?.data['errors'];
          return {
            'success': false,
            'message': errors.values.first[0].toString(),
          };
        }
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Gagal mengupdate produk',
        };
      }
      return {'success': false, 'message': 'Koneksi ke server bermasalah'};
    }
  }

  Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final response = await _apiClient.dio.delete('/products/$id');
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Produk berhasil dihapus.'};
      }
      return {'success': false, 'message': 'Gagal menghapus produk.'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Koneksi bermasalah',
      };
    }
  }

  // ... (fungsi getCategories, getAddOns, addAddOn, deleteAddOn biarin sama kayak punya lu)
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('/categories');
      return response.data['data'] ?? response.data;
    } catch (e) {
      print("Error fetch categories: $e");
      return [];
    }
  }

  Future<List<dynamic>> getAddOns() async {
    try {
      final response = await _apiClient.dio.get('/addons');
      return response.data['data'] ?? response.data;
    } catch (e) {
      print("Error fetch addons: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> addAddOn(String nama, String harga) async {
    try {
      final response = await _apiClient.dio.post(
        '/addons',
        data: {'nama_addon': nama, 'harga_addon': harga},
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Add-on berhasil ditambahkan'};
      }
      return {'success': false, 'message': 'Gagal menambah Add-on'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAddOn(int id) async {
    try {
      final response = await _apiClient.dio.delete('/addons/$id');
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Add-on berhasil dihapus'};
      }
      return {'success': false, 'message': 'Gagal menghapus Add-on'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
