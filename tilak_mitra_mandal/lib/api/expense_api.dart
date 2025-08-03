import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
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
      throw Exception(e.response?.data['error'] ?? 'Failed to fetch expenses');
    }
  }

  /// Fetch total expenses amount
  static Future<Map<String, dynamic>> getTotalExpenses(String token) async {
    try {
      final res = await ApiClient.dio.get(
        '/expenses/total',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to fetch total expenses',
      );
    }
  }

  /// Add a new expense
  static Future<Map<String, dynamic>> addExpense({
    required String token,
    required double amount,
    required String description,
    required String purpose,
    required String spentBy,
    File? receipt,
  }) async {
    try {
      // Debug: Print the values being sent
      print('Sending expense data:');
      print('Amount: $amount');
      print('Description: $description');
      print('Purpose: $purpose');
      print('Spent By: $spentBy');

      Map<String, dynamic> formDataMap = {
        'amount': amount.toString(),
        'description': description,
        'purpose': purpose,
        'spentBy': spentBy,
      };

      // Add receipt file if provided
      if (receipt != null) {
        // Get file extension and determine content type
        final extension = receipt.path.toLowerCase().split('.').last;
        MediaType contentType = MediaType('image', 'jpeg'); // default

        switch (extension) {
          case 'png':
            contentType = MediaType('image', 'png');
            break;
          case 'jpg':
          case 'jpeg':
            contentType = MediaType('image', 'jpeg');
            break;
          case 'gif':
            contentType = MediaType('image', 'gif');
            break;
          case 'bmp':
            contentType = MediaType('image', 'bmp');
            break;
          case 'webp':
            contentType = MediaType('image', 'webp');
            break;
          case 'pdf':
            contentType = MediaType('application', 'pdf');
            break;
        }

        formDataMap['receipt'] = await MultipartFile.fromFile(
          receipt.path,
          contentType: contentType,
          filename: 'receipt.$extension',
        );
      }

      final formData = FormData.fromMap(formDataMap);

      // Debug: Print form data fields
      print('Form data fields:');
      for (var field in formData.fields) {
        print('${field.key}: ${field.value}');
      }

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

      // Debug: Print response
      print('Response: ${res.data}');

      return res.data;
    } on DioException catch (e) {
      // Enhanced error handling
      String errorMessage = 'Add expense failed';

      if (e.response != null) {
        final responseData = e.response!.data;
        print('Error response: $responseData'); // Debug print

        if (responseData is Map<String, dynamic>) {
          errorMessage =
              responseData['message'] ??
              responseData['error'] ??
              'Server returned ${e.response!.statusCode} error';
        } else if (responseData is String) {
          errorMessage = responseData;
        } else {
          errorMessage = 'Server returned ${e.response!.statusCode} error';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server is taking too long to respond.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Unable to connect to server. Please check your internet connection.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('Unexpected error: $e'); // Debug print
      throw Exception('Unexpected error: ${e.toString()}');
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
      // Debug: Print the values being sent
      print('Updating expense data:');
      print('ID: $id');
      print('Amount: $amount');
      print('Description: $description');
      print('Purpose: $purpose');
      print('Spent By: $spentBy');

      Map<String, dynamic> formDataMap = {
        'amount': amount.toString(),
        'description': description,
        'purpose': purpose,
        'spentBy': spentBy,
      };

      // Add receipt file if provided
      if (receipt != null) {
        // Get file extension and determine content type
        final extension = receipt.path.toLowerCase().split('.').last;
        MediaType contentType = MediaType('image', 'jpeg'); // default

        switch (extension) {
          case 'png':
            contentType = MediaType('image', 'png');
            break;
          case 'jpg':
          case 'jpeg':
            contentType = MediaType('image', 'jpeg');
            break;
          case 'gif':
            contentType = MediaType('image', 'gif');
            break;
          case 'bmp':
            contentType = MediaType('image', 'bmp');
            break;
          case 'webp':
            contentType = MediaType('image', 'webp');
            break;
          case 'pdf':
            contentType = MediaType('application', 'pdf');
            break;
        }

        formDataMap['receipt'] = await MultipartFile.fromFile(
          receipt.path,
          contentType: contentType,
          filename: 'receipt.$extension',
        );
      }

      final formData = FormData.fromMap(formDataMap);

      // Debug: Print form data fields
      print('Form data fields:');
      for (var field in formData.fields) {
        print('${field.key}: ${field.value}');
      }

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

      // Debug: Print response
      print('Response: ${res.data}');

      return res.data;
    } on DioException catch (e) {
      // Enhanced error handling
      String errorMessage = 'Update expense failed';

      if (e.response != null) {
        final responseData = e.response!.data;
        print('Error response: $responseData'); // Debug print

        if (responseData is Map<String, dynamic>) {
          errorMessage =
              responseData['message'] ??
              responseData['error'] ??
              'Server returned ${e.response!.statusCode} error';
        } else if (responseData is String) {
          errorMessage = responseData;
        } else {
          errorMessage = 'Server returned ${e.response!.statusCode} error';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server is taking too long to respond.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Unable to connect to server. Please check your internet connection.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('Unexpected error: $e'); // Debug print
      throw Exception('Unexpected error: ${e.toString()}');
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