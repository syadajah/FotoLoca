import 'package:dio/dio.dart';
import 'package:fotoloca/core/network/api_client.dart'; // Sesuaikan path

class ActivityLogServices {
  final ApiClient _apiClient = ApiClient();

  // Tambahkan parameter opsional {int? userId}
  Future<Map<String, dynamic>> getLogs({int? userId}) async {
    try {
      String url = '/activity-logs';

      // Kalau ada userId yang dikirim, tambahin ke URL
      if (userId != null) {
        url += '?user_id=$userId';
      }

      final response = await _apiClient.dio.get(url);
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'message': 'Gagal mengambil log aktivitas'};
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }
}
