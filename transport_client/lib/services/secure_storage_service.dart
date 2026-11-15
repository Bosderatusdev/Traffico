import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _nomKey = 'user_nom';
  static const _roleKey = 'user_role';

  static Future<void> saveSession({
    required String token,
    required int userId,
    required String role,
    required String nom,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _nomKey, value: nom);
  }

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<String?> getRole() => _storage.read(key: _roleKey);
  static Future<String?> getNom() => _storage.read(key: _nomKey);

  static Future<int?> getUserId() async {
    final value = await _storage.read(key: _userIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}
