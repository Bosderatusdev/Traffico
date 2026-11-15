import 'package:dio/dio.dart';
import 'package:transport_client/models/notification_item.dart';
import 'package:transport_client/services/api_client.dart';
import 'package:transport_client/services/auth_service.dart';
import 'package:transport_client/services/secure_storage_service.dart';

class NotificationService {
  final Dio _dio = ApiClient.dio;

  Future<List<NotificationItem>> fetchAll() async {
    try {
      final userId = await SecureStorageService.getUserId();
      if (userId == null) {
        throw ApiException("Utilisateur non connecté !");
      }
      
      final response = await _dio.get('/api/notifications/user/$userId');
      final List data = response.data as List;
      return data.map((json) => NotificationItem.fromJson(json)).toList();
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ??
                e.response?.data['error'] ??
                'Erreur de chargement')
          : 'Erreur de chargement';
      throw ApiException(message.toString());
    }
  }

  Future<void> marqueLue(int id) async {
    try {
      
      await _dio.put('/api/notifications/$id/read');
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ??
                e.response?.data['error'] ??
                'Erreur')
          : 'Erreur';
      throw ApiException(message.toString());
    }
  }
}
