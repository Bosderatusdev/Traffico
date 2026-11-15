import 'package:dio/dio.dart';
import 'package:transport_client/models/login_response.dart';
import '../models/register_response.dart';
import 'api_client.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<RegisterResponse> register({
    required String nom,
    required String prenom,
    required String telephone,
    String? email,
    required String motDePasse,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'nom': nom,
          'prenom': prenom,
          'telephone': telephone,
          if (email != null) 'email': email,
          'motDePasse': motDePasse,
        },
      );
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  //velification et le renvoi du code

  Future<String> verifyCode({
    required int userId,
    required String code,
    required String type, // on utilise 'phone' ou'email'
  }) async {
    final endpoint = type == 'email'
        ? '/api/auth/verify-email'
        : '/api/auth/verify-phone';

    try {
      final response = await _dio.post(
        endpoint,
        data: {'userId': userId.toString(), 'code': code},
      );
      return response.data['message'] as String;
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Le serveur met trop de temps à répondre.';
      case DioExceptionType.connectionError:
        return 'Impossible de contacter le serveur. Vérifiez votre connexion Internet.';

      default:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  // To resend le code de verification

  Future<String> resendCode({
    required int userId,
    required String type, // 'phone' or 'email'
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/resend-code',
        data: {'userId': userId.toString(), 'type': type},
      );
      return response.data['message'] as String;
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<LoginResponse> login({
    required String identifiant,
    required String motDePasse,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'identifiant': identifiant, 'motDePasse': motDePasse},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  //concernat le mot de passe oubliée

  Future<String> forgotPassword({required String identifiant}) async {
  try {
    final response = await _dio.post('/api/auth/forgot-password', data: {
      'identifiant': identifiant,
    });
    return response.data['message'] as String;
  } on DioException catch (e) {
    throw ApiException(_extractErrorMessage(e));
  }
  }

  Future<String> resetPassword({
    required String identifiant,
    required String code,
    required String nouveauMotDePasse,
  }) async {
  try {
    final response = await _dio.post('/api/auth/reset-password', data: {
      'identifiant': identifiant,
      'code': code,
      'nouveauMotDePasse': nouveauMotDePasse,
    });
    return response.data['message'] as String;
  } on DioException catch (e) {
    throw ApiException(_extractErrorMessage(e));
    }
  }
  
}
