import 'dart:async';
import 'package:flutter_application_2/models/employee.dart';
import 'package:flutter_application_2/models/user.dart';
import 'package:flutter_application_2/utils/preference.dart';
import 'package:flutter_application_2/utils/response_result.dart';
import 'package:flutter_application_2/utils/urls.dart';

class AuthService {
  Future<ResponseResult<User>> login(String email, String password) async {
    final response = await Urls.postUrl(
      '/auth/login',
      {'email': email, 'password': password},
      {'Content-Type': 'application/json'},
    );

    if (response['status'] == false) {
      return ResponseResult.error(
        message: response['message'] ?? 'Error en el login',
        errorCode: 'LOGIN_FAILED',
      );
    }

    final User user = User.fromJson(response['data']);

    // Guardar usuario usando el servicio centralizado
    await PreferenceUtils.saveCurrentUser(user.toJson());
    Employee().fromJson(response['data']);

    return ResponseResult<User>.success(
      message: response['message'] ?? 'Login exitoso',
      data: user,
    );
  }

  // Obtener usuario actual usando el servicio centralizado
  Future<Map<String, dynamic>?> getCurrentUser() async {
    return await PreferenceUtils.getCurrentUser();
  }

  // Verificar si hay sesión activa
  Future<bool> isLoggedIn() async {
    return await PreferenceUtils.isLoggedIn();
  }

  // Cerrar sesión
  Future<void> logout() async {
    await PreferenceUtils.logout();
  }

  // Limpiar todos los datos (uso en casos extremos)
  Future<void> cleanAllData() async {
    await PreferenceUtils.clearAllData();
  }
}
