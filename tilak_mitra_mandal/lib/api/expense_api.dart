// lib/api/collection_api.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tilak_mitra_mandal/api/api_client.dart';

class CollectionApi {
  static Future<List<dynamic>> getCollections(String token) async {
    try {
      final res = await ApiClient.dio.get(
        '/collection',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      return res.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch collections');
    }
  }

  static Future<Map<String, dynamic>> addCollection({
    required String token,
    required double amount,
    required String collectedBy,
    File? receipt,
  }) async {
    try {
      final formData = FormData.fromMap({
        'amount': amount.toString(),
        'collectedBy': collectedBy,
        if (receipt != null)
          'receipt': await MultipartFile.fromFile(receipt.path),
      });

      final res = await ApiClient.dio.post(
        '/collection',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        }),
      );

      return res.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Add collection failed');
    }
  }

  static Future<void> deleteCollection(String id, String token) async {
    try {
      await ApiClient.dio.delete(
        '/collection/$id',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Delete failed');
    }
  }
}
