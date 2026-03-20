import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fotoloca/core/network/api_client.dart';

class ProductServices {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> addProducts({
    required String idKategori,
    required String namaProduk,
    required String hargaProduk,
    required String deskripsi,
    File? foto,
  }) async {
    try {
      //Bungkus teks ke dalam formData
      FormData formData = FormData.fromMap({
        'id_kategori': idKategori,
        'nama_produk': namaProduk,
        'harga_produk': hargaProduk,
        'deskripsi': deskripsi,
      });

      //Jika ada foto sisipkan ke dalam formdata
      if (foto != null) {
        String fileName = foto.path.split('/').last;
        formData.files.add(
          MapEntry(
            'foto',
            await MultipartFile.fromFile(foto.path, filename: fileName),
          ),
        );
      }
      //Tembak ke laravel
      final response = await _apiClient.dio.post('/products', data: formData);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Produk berhasil ditambahkan.'};
      }
      return {'success': false, 'message': 'Gagal menyimpan produk.'};
    } on DioException catch (e) {
      String errorMessage = 'Koneksi ke server bermasalah';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  //Fungsi mengambil daftar produk
  Future<List<dynamic>> showProducts() async {
    try {
      final response = await _apiClient.dio.get('/products');
      if (response.statusCode == 200) {
        return response.data['data'];
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
    File? foto,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        '_method': 'PUT',
        'id_kategori': idKategori,
        'nama_produk': namaProduk,
        'harga_produk': hargaProduk,
        'deskripsi': deskripsi,
      });

      //Jika user memilih foto baru, tambahkan ke form data
      if (foto != null) {
        String fileName = foto.path.split('/').last;
        formData.files.add(
          MapEntry(
            'foto',
            await MultipartFile.fromFile(foto.path, filename: fileName),
          ),
        );
      }

      final response = await _apiClient.dio.post(
        '/products/$id',
        data: formData,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Produk berhasil diupdate.'};
      }
      return {'success': false, 'message': 'Gagal mengupdate produk.'};
    } on DioException catch (e) {
      String errorMessage = 'Koneksi ke server bermasalah';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final response = await _apiClient.dio.delete('/products/$id');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Produk berhasil dihapus.'};
      }
      return {'suuccess': false, 'message': 'Gagal menghapus produk.'};
    } on DioException catch (e) {
      String errorMessage = 'Koneksi ke server bermasalah';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      return {'success': false, 'message': errorMessage};
    }
  }
}
