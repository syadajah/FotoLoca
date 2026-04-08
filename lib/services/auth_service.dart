import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fotoloca/core/network/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- 1. FUNGSI LOGIN ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final String token = response.data['token'];
        final String role = response.data['role'];

        // Simpan ke storage (biarin aja ini kalau udah ada)
        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'user_role', value: role);

        return {
          'success': true,
          'message': response.data['message'] ?? 'Login berhasil',
          'token': token, // <--- TAMBAHIN INI BIAR TOKEN NYAMPE KE LOGIN.DART
          'role': role,
          'data': response
              .data['data'], // <--- INI DIA BIANG KEROKNYA! BAWA DATANYA!
        };
      }
      return {'success': false, 'message': 'Gagal memproses data.'};
    } on DioException catch (e) {
      String errorMessage = 'Koneksi ke server bermasalah';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  // --- 2. FUNGSI LOGOUT ---
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/logout');
      print("Token berhasil dimatikan di server laravel.");
    } on DioException catch (e) {
      print("Gagal mematikan token di server: ${e.message}");
    } finally {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_role');
      print("Data lokal berhasil dihapus.");
    }
  }
}
