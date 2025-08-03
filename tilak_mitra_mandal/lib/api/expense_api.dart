import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tilak_mitra_mandal/api/api_client.dart';

class ExpenseApi {
  /// Fetch all expenses
  static Future<List<dynamic>> getExpenses(String token) async {
    try {
      final res = await ApiClient.dio.get(
        '/expenses',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to fetch expenses',
      );
    }
  }

  /// Add a new expense
  static Future<Map<String, dynamic>> addExpense({
    required String token,
    required double amount,
    required String description,  // Made required to match backend
    required String purpose,      // Made required to match backend
    required String spentBy,      // Made required to match backend
    File? receipt,
  }) async {
    try {
      final formData = FormData.fromMap({
        'amount': amount.toString(),
        'description': description,
        'purpose': purpose,
        'spentBy': spentBy,
        if (receipt != null)
          'receipt': await MultipartFile.fromFile(receipt.path),
      });

      final res = await ApiClient.dio.post(
        '/expenses',
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
      throw Exception(e.response?.data['error'] ?? 'Add expense failed');
    }
  }

  /// Update an existing expense
  static Future<Map<String, dynamic>> updateExpense({
    required String id,
    required String token,
    required double amount,
    required String description,
    required String purpose,
    required String spentBy,
    File? receipt,
  }) async {
    try {
      final formData = FormData.fromMap({
        'amount': amount.toString(),
        'description': description,
        'purpose': purpose,
        'spentBy': spentBy,
        if (receipt != null)
          'receipt': await MultipartFile.fromFile(receipt.path),
      });

      final res = await ApiClient.dio.put(
        '/expenses/$id',
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
      throw Exception(e.response?.data['error'] ?? 'Update expense failed');
    }
  }

  /// Delete an expense by ID
  static Future<void> deleteExpense(String id, String token) async {
    try {
      await ApiClient.dio.delete(
        '/expenses/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Delete expense failed');
    }
  }
}