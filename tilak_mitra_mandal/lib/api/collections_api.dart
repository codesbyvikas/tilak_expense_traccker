// lib/api/collection_api.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tilak_mitra_mandal/api/api_client.dart';

class CollectionApi {
  // Fetch all collections
  static Future<List<dynamic>> getCollections(String token) async {
    try {
      final res = await ApiClient.dio.get(
        '/collections',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to fetch collections',
      );
    }
  }

  // Add a new collection
  static Future<Map<String, dynamic>> addCollection({
    required String token,
    required double amount,
    required String collectedBy,
    required String collectedFrom,
    String? description,
    File? receipt,
  }) async {
    try {
      final formData = FormData.fromMap({
        'amount': amount.toString(),
        'collectedBy': collectedBy,
        'collectedFrom': collectedFrom,
        if (description != null) 'description': description,
        if (receipt != null)
          'receipt': await MultipartFile.fromFile(receipt.path),
      });

      final res = await ApiClient.dio.post(
        '/collections',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return res.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Add collection failed');
    }
  }

  // Delete collection by ID
  static Future<void> deleteCollection(String id, String token) async {
    try {
      await ApiClient.dio.delete(
        '/collections/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Delete failed');
    }
  }
}
