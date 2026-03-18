import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // 1. Mencegat Request SEBELUM dikirim ke Laravel
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Ambil token dari storage
    final token = await storage.read(key: 'auth_token');

    // Jika token ada, masukkan ke header Authorization
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Log untuk memudahkan Anda melihat URL dan Data yang dikirim di terminal
    print('MENGIRIM: ${options.method} ${options.uri}');
    if (options.data != null) print('📦 DATA: ${options.data}');

    super.onRequest(options, handler); // Lanjutkan perjalanan request
  }

  // 2. Mencegat Response SETELAH mendapat balasan sukses dari Laravel
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('SUKSES: ${response.statusCode} | URL: ${response.requestOptions.uri}');
    super.onResponse(response, handler);
  }

  // 3. Mencegat Error JIKA terjadi kegagalan
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR: ${err.response?.statusCode} | URL: ${err.requestOptions.uri}');
    print('Pesan Error: ${err.message}');
    
    // Jika error dari Laravel ada isinya (misal pesan validasi salah)
    if (err.response?.data != null) {
      print('Detail Error dari Laravel: ${err.response?.data}');
    }

    // Nanti Anda bisa tambahkan logic di sini:
    // Jika statusCode == 401 (Token Expired), arahkan user kembali ke halaman Login.

    super.onError(err, handler);
  }
}