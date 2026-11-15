import 'package:dio/dio.dart';
import '../models/trajet.dart';
import 'api_client.dart';
import 'auth_service.dart';

class TrajetService {
  final Dio _dio = ApiClient.dio;

  Future<List<Trajet>> search({
    required String depart,
    required String arrivee,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/api/trajets/search',
        queryParameters: {
          'depart': depart,
          'arrivee': arrivee,
        },
        cancelToken: cancelToken,
      );

      final List data = response.data as List;
      return data.map((json) => Trajet.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow; // on ignore silencieusement les recherches annulées
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'] ?? 'Erreur de recherche')
          : 'Erreur de recherche';
      throw ApiException(message.toString());
    }
  }
}