import 'package:flutter_application_2/models/user.dart';
import 'package:flutter_application_2/utils/storage_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static const _storage = FlutterSecureStorage();

  // ========== CREDENCIALES (Remember Me) ==========

  static Future<void> saveCredentials(
    String email,
    String password,
    bool remember,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    if (remember) {
      await prefs.setString(StorageKeys.savedEmail, email);
      await prefs.setBool(StorageKeys.rememberMe, true);
      await _storage.write(key: StorageKeys.savedPassword, value: password);
    } else {
      await clearSavedCredentials();
    }
  }

  static Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(StorageKeys.savedEmail);
    final password = await _storage.read(key: StorageKeys.savedPassword);
    final remember = prefs.getBool(StorageKeys.rememberMe) ?? false;

    return {
      'email': email,
      'password': password,
      'remember': remember.toString(),
    };
  }

  static Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.savedEmail);
    await prefs.remove(StorageKeys.rememberMe);
    await _storage.delete(key: StorageKeys.savedPassword);
  }

  // ========== USUARIO ACTUAL ==========

  static Future<void> saveCurrentUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(StorageKeys.currentUserDni, userData['dni'] ?? '');
    await prefs.setString(
      StorageKeys.currentUserName,
      userData['nombre'] ?? '',
    );
    await prefs.setString(
      StorageKeys.currentUserFullname,
      userData['apellidos'] ?? '',
    );
    await prefs.setString(
      StorageKeys.currentUserAddress,
      userData['direccion'] ?? '',
    );
    await prefs.setInt(
      StorageKeys.currentUserHours,
      userData['contratosHoras'] ?? 0,
    );
    await prefs.setString(
      StorageKeys.currentUserEmail,
      userData['email'] ?? '',
    );
    await prefs.setBool(StorageKeys.isLoggedIn, true);

    // Si hay token, guardarlo de forma segura
    if (userData['token'] != null) {
      await _storage.write(
        key: StorageKeys.authToken,
        value: userData['token'],
      );
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'dni': prefs.getString(StorageKeys.currentUserDni) ?? '',
      'nombre': prefs.getString(StorageKeys.currentUserName) ?? '',
      'apellidos': prefs.getString(StorageKeys.currentUserFullname) ?? '',
      'direccion': prefs.getString(StorageKeys.currentUserAddress) ?? '',
      'email': prefs.getString(StorageKeys.currentUserEmail) ?? '',
      'contratosHoras': prefs.getInt(StorageKeys.currentUserHours) ?? 0,
      'token': await _storage.read(key: StorageKeys.authToken),
    };
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  // ========== TOKENS DE AUTENTICACIÓN ==========

  static Future<void> saveAuthTokens(
    String? authToken, [
    String? refreshToken,
  ]) async {
    if (authToken != null) {
      await _storage.write(key: StorageKeys.authToken, value: authToken);
    }
    if (refreshToken != null) {
      await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    }
  }

  static Future<String?> getAuthToken() async {
    return await _storage.read(key: StorageKeys.authToken);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  // ========== LIMPIAR TODO ==========

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _storage.deleteAll();
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Mantener credenciales guardadas si el usuario las tenía
    final remember = prefs.getBool(StorageKeys.rememberMe) ?? false;
    final savedEmail = prefs.getString(StorageKeys.savedEmail);
    final savedPassword = await _storage.read(key: StorageKeys.savedPassword);

    // Limpiar datos del usuario actual
    await prefs.remove(StorageKeys.currentUserDni);
    await prefs.remove(StorageKeys.currentUserName);
    await prefs.remove(StorageKeys.currentUserEmail);
    await prefs.setBool(StorageKeys.isLoggedIn, false);

    // Limpiar tokens
    await _storage.delete(key: StorageKeys.authToken);
    await _storage.delete(key: StorageKeys.refreshToken);

    // Restaurar credenciales si estaban guardadas
    if (remember && savedEmail != null && savedPassword != null) {
      await prefs.setString(StorageKeys.savedEmail, savedEmail);
      await prefs.setBool(StorageKeys.rememberMe, true);
      await _storage.write(
        key: StorageKeys.savedPassword,
        value: savedPassword,
      );
    }
  }

  // ========== UTILIDADES DE DEBUG ==========

  static Future<Map<String, dynamic>> getAllStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    Map<String, dynamic> data = {};

    // SharedPreferences data
    for (String key in allKeys) {
      data[key] = prefs.get(key);
    }

    // SecureStorage data (solo claves, no valores por seguridad)
    data['secure_storage_keys'] = [
      StorageKeys.savedPassword,
      StorageKeys.authToken,
      StorageKeys.refreshToken,
    ];

    return data;
  }
}
