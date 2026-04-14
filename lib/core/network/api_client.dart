import 'package:dio/dio.dart';
import 'api_interceptor.dart'; // Import interceptor yang baru kita buat

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    // 1. Konfigurasi Dasar Dio
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.159.186.123:8000/api',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json', // Memaksa Laravel membalas dengan JSON
          'Content-Type': 'application/json',
        },
      ),
    );

    // 2. Daftarkan Interceptor
    _dio.interceptors.add(ApiInterceptor());
  }

  // 3. Buat getter agar instance Dio ini bisa dipakai oleh file service lain
  Dio get dio => _dio;
}
