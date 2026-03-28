import 'package:dio/dio.dart';
import 'api_interceptor.dart'; // Import interceptor yang baru kita buat

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    // 1. Konfigurasi Dasar Dio
    _dio = Dio(
      BaseOptions(
        // Ganti dengan IP komputer/laptop Anda jika testing di device asli.
        // Jika pakai emulator Android, gunakan 10.0.2.2.
        // Jangan pakai localhost atau 127.0.0.1 di emulator.
        baseUrl: 'http://10.10.30.16:8000/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
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
