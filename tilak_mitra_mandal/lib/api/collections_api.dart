import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
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
      // Debug: Print the values being sent
      print('Sending data:');
      print('Amount: $amount');
      print('Collected By: $collectedBy');
      print('Collected From: $collectedFrom');
      print('Description: $description');

      Map<String, dynamic> formDataMap = {
        'amount': amount.toString(),
        'collectedBy': collectedBy,
        'collectedFrom': collectedFrom,
      };

      // Add description if provided
      if (description != null && description.isNotEmpty) {
        formDataMap['description'] = description;
      }

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
        '/collections',
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
      String errorMessage = 'Add collection failed';

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
