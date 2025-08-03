// lib/api/auth_api.dart
import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthApi {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print(email);
      print(password);
      final response = await ApiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      print(response.data);
      return response.data; // contains `token` and `user`
    } on DioException catch (e) {
      print(e.message);
      // Handle different types of errors
      if (e.response != null) {
        print(e.response);
        final errorMessage = e.response?.data['message'] ?? 'Login failed';
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server is taking too long to respond.');
      } else {
        throw Exception('Network error. Please try again.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  // Optional: Add other auth methods
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      return response.data;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Registration failed';
      throw Exception(errorMessage);
    }
  }

  static Future<void> logout() async {
    try {
      await ApiClient.dio.post('/auth/logout');
    } on DioException catch (e) {
      print(e.toString());
      // Handle logout errors if needed
      throw Exception('Logout failed $e');
    }
  }
}
