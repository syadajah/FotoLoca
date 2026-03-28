import 'package:dio/dio.dart';
import 'package:fotoloca/core/network/api_client.dart';

class UserServices {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> addUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      };

      if (email.trim().isNotEmpty) {
        requestData['email'] = email.trim();
      }

      final response = await _apiClient.dio.post('/users', data: requestData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Pengguna berhasil ditambahkan'};
      }
      return {'success': false, 'message': 'Gagal menambah pengguna'};
    } on DioException catch (e) {
      String errorMessage = 'Koneksi ke server bermasalah';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _apiClient.dio.get('/users');

      return response.data['data'] ?? [];
    } catch (e) {
      print("Error get users: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required int id,
    required String name,
    required String username,
    required String role,
    String? password,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'username': username,
        'role': role,
      };

      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }

      final response = await _apiClient.dio.put('/users/$id', data: data);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Data pengguna berhasil diupdate'};
      }
      return {'success': false, 'message': 'Gagal mengupdate pengguna'};
    } on DioException catch (e) {
      String errorMessage = 'Koneksi ke server bermasalah';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<Map<String, dynamic>> toggleUserStatus(int id) async {
    try {
      final response = await _apiClient.dio.patch('/users/$id/toggle-status');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
          'is_active': response.data['is_active'],
        };
      }
      return {'success': false, 'message': 'Gagal mengubah status'};
    } on DioException catch (e) {
      String errorMessage = 'Koneksi ke server bermasalah';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      return {'success': false, 'message': errorMessage};
    }
  }
}
