
import 'package:dio/dio.dart';
import 'package:transport_client/models/reservation.dart';
import 'package:transport_client/services/api_client.dart';
import 'package:transport_client/services/auth_service.dart';
import 'package:transport_client/services/secure_storage_service.dart';

class ReservationService {
  final Dio _dio = ApiClient.dio;

  Future<List<Reservation>> creer({
    required int trajetId,
    required int nombrePlaces
  }) async{
    try {
      final response = await _dio.post('/api/reservations',data :{
        'trajetId':trajetId,
        'nombrePlaces':nombrePlaces
      });

      final List data = response.data as List;
      return data.map((json) => Reservation.fromJson(json)).toList();
    } on DioException catch(e){
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'] ?? 'Erreur de réservation')
          : 'Erreur de réservation';
      throw ApiException(message.toString());
    }
  }

  Future<List<Reservation>> mesReservations() async{
    try{
      final userId = await SecureStorageService.getUserId();

      if(userId == null){
        throw ApiException('Utilisateur non connecté');
      }

      final response = await _dio.get('/api/reservations/user/$userId');
      final List data = response.data as List;

      return data.map((json) => Reservation.fromJson(json)).toList();
    } on DioException catch(e){

      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'] ?? 'Erreur de chargement')
          : 'Erreur de chargement';
      throw ApiException(message.toString());
    }
  }

  Future<void> supprimer(int id) async {
  try {
    await _dio.delete('/api/reservations/$id');
  } on DioException catch (e) {
    final message = e.response?.data is Map
        ? (e.response?.data['message'] ?? e.response?.data['error'] ?? 'Erreur de suppression')
        : 'Erreur de suppression';
    throw ApiException(message.toString());
  }
}
}
