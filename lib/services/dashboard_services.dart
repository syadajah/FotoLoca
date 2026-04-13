import 'package:dio/dio.dart';
import 'package:fotoloca/core/network/api_client.dart'; // Sesuaikan path api_client lu

class DashboardServices {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      // Nembak ke route yang udah kita arahin ke DashboardController di Laravel
      final response = await _apiClient.dio.get('/dashboard');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'message': 'Gagal mengambil data dashboard'};
    } on DioException catch (e) {
      String errorMessage = 'Koneksi ke server bermasalah';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
