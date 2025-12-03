import 'package:flutter_application_2/models/event.dart';
import 'package:flutter_application_2/models/request_event.dart';
import 'package:flutter_application_2/utils/response_result.dart';
import 'package:flutter_application_2/utils/urls.dart';

class EventService {
  Future<ResponseResult<List<Event>>> getEvents() async {
    final response = await Urls.getUrl('/events', {
      'Content-Type': 'application/json',
    });

    if (response['status'] == false) {
      return ResponseResult.error(
        message: response['message'] ?? 'Error al cargar eventos',
      );
    }

    final eventsData = response['data'];
    return ResponseResult<List<Event>>.success(
      message: 'Eventos cargados correctamente',
      data:
          eventsData
              .map<Event>((eventJson) => Event.fromJson(eventJson))
              .toList(),
    );
  }

  Future<ResponseResult<List<Event>>> getEventsByEmployee(String dni) async {
    final response = await Urls.postUrl(
      '/events/employee',
      {'dni': dni},
      {'Content-Type': 'application/json'},
    );

    if (response['status'] == false) {
      return ResponseResult.error(
        message:
            response['message'] ?? 'Error al cargar eventos para el empleado',
      );
    }

    final eventsData = response['data'];
    return ResponseResult<List<Event>>.success(
      message: 'Eventos para el empleado cargados correctamente',
      data:
          eventsData
              .map<Event>((eventJson) => Event.fromJson(eventJson))
              .toList(),
    );
  }

  Future<ResponseResult<List<RequestEvent>>> getRequestEvents() async {
    final response = await Urls.getUrl('/events/requestEvents', {
      'Content-Type': 'application/json',
    });

    if (response['status'] == false) {
      return ResponseResult.error(
        message: response['message'] ?? 'Error al cargar eventos de solicitud',
      );
    }
    final requestEventsData = response['data'];
    return ResponseResult<List<RequestEvent>>.success(
      message: 'Eventos de solicitud cargados correctamente',
      data:
          requestEventsData
              .map<RequestEvent>(
                (eventJson) => RequestEvent.fromJson(eventJson),
              )
              .toList(),
    );
  }

  Future<ResponseResult<void>> prepareEvent({
    required String eventCode,
    required DateTime fechaIni,
    required DateTime fechaFin,
    required DateTime horaPrevistaInicio,
    required double presupuesto,
    required List<Map<String, dynamic>> selectedInternalStaff,
    required List<Map<String, dynamic>> selectedExternalStaff,
    required List<Map<String, dynamic>> selectedInventoryMaterial,
    required List<Map<String, dynamic>> selectedRentalMaterial,
  }) async {
    final body = {
      "eventCode": eventCode,
      "fechaIni": fechaIni.toIso8601String(),
      "fechaFin": fechaFin.toIso8601String(),
      "horaPrevistaInicio": horaPrevistaInicio.toIso8601String(),
      "presupuesto": presupuesto,
      "staffInternal": selectedInternalStaff,
      "staffExternal": selectedExternalStaff,
      "materialsInventory": selectedInventoryMaterial,
      "materialsRental": selectedRentalMaterial,
    };

    final response = await Urls.postUrl('/events/prepare', body, {
      'Content-Type': 'application/json',
    });

    if (response['status'] == false) {
      return ResponseResult.error(
        message: response['message'] ?? 'Error al preparar el evento',
      );
    }

    return ResponseResult.success(message: 'Evento preparado correctamente');
  }

  Future<ResponseResult<void>> updatePresupuestoFinal(
    String codEvento,
    double presupuestoFinal,
  ) async {
    try {
      final response = await Urls.putUrl(
        '/events/$codEvento/presupuesto-final',
        {'presupuestoModificado': presupuestoFinal},
        {'Content-Type': 'application/json'},
      );

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error actualizando presupuesto',
          errorCode: 'UPDATE_PRESUPUESTO_FAILED',
        );
      }

      return ResponseResult.success(
        message: 'Presupuesto actualizado exitosamente',
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }
}
