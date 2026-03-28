import 'package:fotoloca/core/network/api_client.dart';

class CategoryServices {
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await ApiClient().dio.get('/categories');

      return response.data['data'] ?? response.data;
    } catch (e) {
      print("Error di CategoryServices.getCategories: $e");
      throw Exception('Gagal mengambil data kategori dari server');
    }
  }

  Future<Map<String, dynamic>> addCategory(String namaKategori) async {
    try {
      final response = await ApiClient().dio.post(
        '/categories',
        data: {'nama_kategori': namaKategori},
      );
      return {'success': true, 'message': 'Kategori berhasil ditambahkan'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal menambah kategori: $e'};
    }
  }

  Future<Map<String, dynamic>> updateCategory(
    int id,
    String namaKategori,
  ) async {
    try {
      final response = await ApiClient().dio.put(
        '/categories/$id',
        data: {'nama_kategori': namaKategori},
      );
      return {'success': true, 'message': 'Kategori berhasil diupdate'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengupdate kategori: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteCategory(int id) async {
    try {
      final response = await ApiClient().dio.delete('/categories/$id');
      return {'success': true, 'message': 'Kategori berhasil dihapus'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghapus kategori: $e'};
    }
  }
}
