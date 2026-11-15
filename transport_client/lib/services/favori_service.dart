import 'package:dio/dio.dart';
import '../models/favori.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'secure_storage_service.dart';

class FavoriService {
  final Dio _dio = ApiClient.dio;

  Future<List<Favori>> mesFavoris() async {
    try {
      final userId = await SecureStorageService.getUserId();
      if (userId == null) throw ApiException('Utilisateur non connecté');
      final response = await _dio.get('/api/favoris/user/$userId');
      final List data = response.data as List;
      return data.map((json) => Favori.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException(_msg(e));
    }
  }

  Future<Favori> ajouterAgence(int agenceId) async {
    try {
      final response = await _dio.post('/api/favoris', data: {
        'type': 'agence',
        'agenceId': agenceId,
      });
      return Favori.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(_msg(e));
    }
  }

  Future<Favori> ajouterTrajet(String villeDepart, String villeArrivee) async {
    try {
      final response = await _dio.post('/api/favoris', data: {
        'type': 'trajet',
        'villeDepart': villeDepart,
        'villeArrivee': villeArrivee,
      });
      return Favori.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(_msg(e));
    }
  }

  Future<void> supprimer(int id) async {
    try {
      await _dio.delete('/api/favoris/$id');
    } on DioException catch (e) {
      throw ApiException(_msg(e));
    }
  }

  String _msg(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }
    return 'Erreur';
  }
}