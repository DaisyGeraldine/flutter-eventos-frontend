import 'package:flutter_application_2/models/employee.dart';
import 'package:flutter_application_2/models/event.dart';
import 'package:flutter_application_2/models/persona.dart';
import 'package:flutter_application_2/models/personal.dart';
import 'package:flutter_application_2/utils/response_result.dart';
import 'package:flutter_application_2/utils/urls.dart';

class PersonalService {
  // ========== OPERACIONES DE PERSONA BASE ==========

  // Obtener todas las personas
  Future<ResponseResult<List<Persona>>> getAllPersonas() async {
    try {
      final response = await Urls.getUrl('/staff/personas', {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error obteniendo personas',
          errorCode: 'FETCH_PERSONAS_FAILED',
        );
      }

      final List<Persona> personas =
          (response['data'] as List)
              .map((item) => Persona.fromJson(item))
              .toList();

      return ResponseResult.success(
        message: 'Personas obtenidas exitosamente',
        data: personas,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Crear persona base
  Future<ResponseResult<Persona>> createPersona(Persona persona) async {
    try {
      final response = await Urls.postUrl('/staff/personas', persona.toJson(), {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error creando persona',
          errorCode: 'CREATE_PERSONA_FAILED',
        );
      }

      final createdPersona = Persona.fromJson(response['data']);

      return ResponseResult.success(
        message: 'Persona creada exitosamente',
        data: createdPersona,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // ========== OPERACIONES DE EMPLEADO ==========

  // Obtener todos los empleados
  Future<ResponseResult<List<EmployeeComplete>>> getAllEmpleados() async {
    try {
      final response = await Urls.getUrl('/staff/empleados', {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error obteniendo empleados',
          errorCode: 'FETCH_EMPLEADOS_FAILED',
        );
      }

      final List<EmployeeComplete> empleados =
          (response['data'] as List)
              .map((item) => EmployeeComplete.fromJson(item))
              .toList();

      return ResponseResult.success(
        message: 'Empleados obtenidos exitosamente',
        data: empleados,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Crear empleado completo (Persona + Empleado)
  Future<ResponseResult<EmployeeComplete>> createEmpleado(EmployeeComplete empleado) async {
    try {
      final response = await Urls.postUrl(
        '/staff/empleados/complete',
        empleado.toJson(),
        {'Content-Type': 'application/json'},
      );

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error creando empleado',
          errorCode: 'CREATE_EMPLEADO_FAILED',
        );
      }

      final createdEmpleado = EmployeeComplete.fromJson(response['data']);

      return ResponseResult.success(
        message: 'Empleado creado exitosamente',
        data: createdEmpleado,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Actualizar empleado
  Future<ResponseResult<EmployeeComplete>> updateEmpleado(EmployeeComplete empleado) async {
    try {
      final response = await Urls.putUrl(
        '/staff/empleados/${empleado.dni}/complete',
        empleado.toJson(),
        {'Content-Type': 'application/json'},
      );

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error actualizando empleado',
          errorCode: 'UPDATE_EMPLEADO_FAILED',
        );
      }

      final updatedEmpleado = EmployeeComplete.fromJson(response['data']);

      return ResponseResult.success(
        message: 'Empleado actualizado exitosamente',
        data: updatedEmpleado,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Actualizar solo estado del empleado
  Future<ResponseResult<EmployeeComplete>> updateEstadoEmpleado(
    String dni,
    EstadoEmpleado nuevoEstado,
  ) async {
    try {
      final response = await Urls.putUrl(
        '/staff/empleados/$dni/estado',
        {'estado': nuevoEstado.name},
        {'Content-Type': 'application/json'},
      );

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error actualizando estado',
          errorCode: 'UPDATE_ESTADO_FAILED',
        );
      }

      final updatedEmpleado = EmployeeComplete.fromJson(response['data']);

      return ResponseResult.success(
        message: 'Estado actualizado exitosamente',
        data: updatedEmpleado,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Eliminar empleado completo
  Future<ResponseResult<void>> deleteEmpleado(String dni) async {
    try {
      final response = await Urls.deleteUrl('/staff/empleados/$dni/complete', {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error eliminando empleado',
          errorCode: 'DELETE_EMPLEADO_FAILED',
        );
      }

      return ResponseResult.success(message: 'Empleado eliminado exitosamente');
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // ========== CONSULTAS ESPECÍFICAS ==========
  // GET /staff/available
  Future<ResponseResult<List<Personal>>> getAvailableInternalStaff() async {
    final response = await Urls.getUrl('/staff/available', {
      'Content-Type': 'application/json',
    });

    if (response['status'] == false) {
      return ResponseResult.error(
        message: response['message'] ?? 'Error al cargar personal interno',
      );
    }

    final staffData = response['data'];
    return ResponseResult<List<Personal>>.success(
      message: 'Personal interno cargado correctamente',
      data:
          staffData
              .map<Personal>((personalJson) => Personal.fromJson(personalJson))
              .toList(),
    );
  }

  // GET /staff/external
  Future<ResponseResult<List<Personal>>> getAvailableExternalStaff() async {
    final response = await Urls.getUrl('/staff/external', {
      'Content-Type': 'application/json',
    });

    if (response['status'] == false) {
      return ResponseResult.error(
        message: response['message'] ?? 'Error al cargar personal externo',
      );
    }

    final staffData = response['data'];
    return ResponseResult<List<Personal>>.success(
      message: 'Personal externo cargado correctamente',
      data:
          staffData
              .map<Personal>((personalJson) => Personal.fromJson(personalJson))
              .toList(),
    );
  }

  // // Empleados disponibles internos
  // Future<ResponseResult<List<Employee>>> getAvailableInternalStaff() async {
  //   try {
  //     final response = await Urls.getUrl('/empleados/available/internal', {
  //       'Content-Type': 'application/json',
  //     });

  //     if (response['status'] == false) {
  //       return ResponseResult.error(
  //         message: response['message'] ?? 'Error obteniendo personal interno',
  //         errorCode: 'FETCH_INTERNAL_STAFF_FAILED',
  //       );
  //     }

  //     final empleadosData = response['data'];
  //     return ResponseResult.success(
  //       message: 'Personal interno cargado correctamente',
  //       data:
  //           empleadosData
  //               .map<Employee>(
  //                 (empleadoJson) => Employee.fromJson(empleadoJson),
  //               )
  //               .toList(),
  //     );
  //   } catch (e) {
  //     return ResponseResult.error(
  //       message: 'Error de conexión: $e',
  //       errorCode: 'NETWORK_ERROR',
  //     );
  //   }
  // }

  // // Empleados disponibles externos (personas externas)
  // Future<ResponseResult<List<Persona>>> getAvailableExternalStaff() async {
  //   try {
  //     final response = await Urls.getUrl('/empleados/available/external', {
  //       'Content-Type': 'application/json',
  //     });

  //     if (response['status'] == false) {
  //       return ResponseResult.error(
  //         message: response['message'] ?? 'Error obteniendo personal externo',
  //         errorCode: 'FETCH_EXTERNAL_STAFF_FAILED',
  //       );
  //     }

  //     final personasData = response['data'];
  //     return ResponseResult.success(
  //       message: 'Personal externo cargado correctamente',
  //       data:
  //           personasData
  //               .map<Persona>((personaJson) => Persona.fromJson(personaJson))
  //               .toList(),
  //     );
  //   } catch (e) {
  //     return ResponseResult.error(
  //       message: 'Error de conexión: $e',
  //       errorCode: 'NETWORK_ERROR',
  //     );
  //   }
  // }

  // Empleados por categoría
  Future<ResponseResult<List<EmployeeComplete>>> getEmpleadosByCategoria(
    CategoriaPersona categoria,
  ) async {
    try {
      final response = await Urls.getUrl(
        '/staff/empleados/categoria/${categoria.name}',
        {'Content-Type': 'application/json'},
      );

      if (response['status'] == false) {
        return ResponseResult.error(
          message:
              response['message'] ?? 'Error obteniendo empleados por categoría',
          errorCode: 'FETCH_CATEGORIA_FAILED',
        );
      }

      final List<EmployeeComplete> empleados =
          (response['data'] as List)
              .map((item) => EmployeeComplete.fromJson(item))
              .toList();

      return ResponseResult.success(
        message: 'Empleados por categoría obtenidos exitosamente',
        data: empleados,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Empleados por estado
  Future<ResponseResult<List<EmployeeComplete>>> getEmpleadosByEstado(
    EstadoEmpleado estado,
  ) async {
    try {
      final response = await Urls.getUrl('/staff/empleados/estado/${estado.name}', {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message:
              response['message'] ?? 'Error obteniendo empleados por estado',
          errorCode: 'FETCH_ESTADO_FAILED',
        );
      }

      final List<EmployeeComplete> empleados =
          (response['data'] as List)
              .map((item) => EmployeeComplete.fromJson(item))
              .toList();

      return ResponseResult.success(
        message: 'Empleados por estado obtenidos exitosamente',
        data: empleados,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  Future<ResponseResult<List<Event>>> getUpcomingEventsForEmpleado(
    String dni,
  ) async {
    try {
      final response = await Urls.getUrl('/staff/empleados/$dni/eventos/proximos', {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error',
          errorCode: 'FETCH_EVENTS',
        );
      }

      final List<Event> events =
          (response['data'] as List).map((e) => Event.fromJson(e)).toList();

      return ResponseResult.success(message: 'Eventos obtenidos', data: events);
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }
}
