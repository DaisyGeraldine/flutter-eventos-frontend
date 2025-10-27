import 'dart:async';
import 'package:flutter_application_2/models/employee.dart';
import 'package:flutter_application_2/models/user.dart';
import 'package:flutter_application_2/utils/preference.dart';
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

class ResponseResult<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;
  final int? statusCode;

  ResponseResult({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
    this.statusCode,
  });

  // Factory constructors para casos comunes
  factory ResponseResult.success({
    required String message,
    T? data,
    int? statusCode,
  }) {
    return ResponseResult<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ResponseResult.error({
    required String message,
    String? errorCode,
    int? statusCode,
  }) {
    return ResponseResult<T>(
      success: false,
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    );
  }

  // Método para verificar si hay datos
  bool get hasData => data != null;

  // Método para obtener datos como mapa
  Map<String, dynamic>? get asMap {
    if (data is Map<String, dynamic>) {
      return data as Map<String, dynamic>;
    }
    return null;
  }

  // Método para obtener datos como lista
  List<T>? get asList {
    if (data is List<T>) {
      return data as List<T>;
    }
    return null;
  }

  @override
  String toString() {
    return 'ResponseResult(success: $success, message: $message, hasData: $hasData)';
  }
}
