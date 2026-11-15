import 'package:dio/dio.dart';
import '../models/user_profile.dart';
import 'api_client.dart';
import 'auth_service.dart';

class UserService {
  final Dio _dio = ApiClient.dio;

  Future<UserProfile> fetchProfile(int userId) async {
    try {
      
      final response = await _dio.get('/api/users/$userId');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(_extractMessage(e));
    }
  }

  Future<UserProfile> updateProfile({
    required int userId,
    required String nom,
    String? prenom,
    String? email,
  }) async {
    try {
      
      final response = await _dio.put('/api/users/$userId', data: {
        'nom': nom,
        if (prenom != null) 'prenom': prenom,
        if (email != null) 'email': email,
      });
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(_extractMessage(e));
    }
  }

  Future<String> changePassword({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    try {
      
      final response = await _dio.put('/api/auth/change-password', data: {
        'ancienMotDePasse': ancienMotDePasse,
        'nouveauMotDePasse': nouveauMotDePasse,
      });
      return response.data['message'] as String? ?? 'Mot de passe modifié';
    } on DioException catch (e) {
      throw ApiException(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }
    return 'Une erreur est survenue';
  }


  // Concernant je veux changer les emails et les téléphones


  Future<String> demanderChangementEmail(int userId, String nouvelEmail) async {
  try {
    final response = await _dio.post('/api/users/$userId/change-email/request', data: {
      'nouvelleValeur': nouvelEmail,
    });
    return response.data['message'] as String;
  } on DioException catch (e) {
    throw ApiException(_extractMessage(e));
  }
}

Future<String> confirmerChangementEmail(int userId, String code) async {
  try {
    final response = await _dio.post('/api/users/$userId/change-email/confirm', data: {
      'code': code,
    });
    return response.data['message'] as String;
  } on DioException catch (e) {
    throw ApiException(_extractMessage(e));
  }
}

Future<String> demanderChangementTelephone(int userId, String nouveauTelephone) async {
  try {
    final response = await _dio.post('/api/users/$userId/change-telephone/request', data: {
      'nouvelleValeur': nouveauTelephone,
    });
    return response.data['message'] as String;
  } on DioException catch (e) {
    throw ApiException(_extractMessage(e));
  }
}

Future<String> confirmerChangementTelephone(int userId, String code) async {
  try {
    final response = await _dio.post('/api/users/$userId/change-telephone/confirm', data: {
      'code': code,
    });
    return response.data['message'] as String;
  } on DioException catch (e) {
    throw ApiException(_extractMessage(e));
  }
}


// concernant un user qui veut supprm son compte 

  Future<String> supprimerCompte(int userId, String motDePasse) async {
  try {
    final response = await _dio.post(
      '/api/users/$userId/delete-self',
      data: {'motDePasse': motDePasse},
    );
    return response.data['message'] as String;
  } on DioException catch (e) {
    throw ApiException(_extractMessage(e));
  }
}


}