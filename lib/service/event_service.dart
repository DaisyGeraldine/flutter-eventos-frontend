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
    // String url = "$_baseUrl/events/employee";
    // Map<String, dynamic> body = {'dni': dni};
    // print('Solicitando eventos para el empleado con DNI $dni a: $url');
    // try {
    //   final response = await http
    //       .post(
    //         Uri.parse(url),
    //         headers: {'Content-Type': 'application/json'},
    //         body: jsonEncode(body),
    //       )
    //       .timeout(const Duration(seconds: 10));
    //   print(response.body);

    //   if (response.statusCode == 200) {
    //     final data = jsonDecode(response.body);

    //     final eventsData = data['data'] as List;
    //     print(
    //       'Eventos recibidos para el empleado con DNI $dni: ${eventsData.length}',
    //     );
    //     print('Datos del Evento: $eventsData');

    //     return eventsData
    //         .map((eventJson) => Event.fromJson(eventJson))
    //         .toList();
    //   } else {
    //     print('Error en la respuesta: ${response.statusCode}');
    //     throw Exception(
    //       'Error al cargar eventos para el empleado: ${response.statusCode}',
    //     );
    //   }
    // } catch (e) {
    //   print('Excepción en getEventsByEmployee: $e');
    //   throw Exception('Error de conexión: $e');
    // }

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
    // String url = "$_baseUrl/events/requestEvents";
    // print('Solicitando eventos de solicitud a: $url');
    // try {
    //   final response = await http
    //       .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
    //       .timeout(const Duration(seconds: 10));

    //   if (response.statusCode == 200) {
    //     final data = jsonDecode(response.body);

    //     final requestEventsData = data['data'] as List;
    //     print('Eventos de solicitud recibidos: ${requestEventsData.length}');
    //     print('Datos del Evento de Solicitud: $requestEventsData');

    //     return requestEventsData
    //         .map((eventJson) => RequestEvent.fromJson(eventJson))
    //         .toList();
    //   } else {
    //     print('Error en la respuesta: ${response.statusCode}');
    //     throw Exception(
    //       'Error al cargar eventos de solicitud: ${response.statusCode}',
    //     );
    //   }
    // } catch (e) {
    //   print('Excepción en getRequestEvents: $e');
    //   throw Exception('Error de conexión: $e');
    // }

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
    required List<String> selectedInternalStaff,
    required List<String> selectedExternalStaff,
    required List<String> selectedInventoryMaterial,
    required List<String> selectedRentalMaterial,
    required String eventCode,
  }) async {
    final body = {
      "eventCode": eventCode,
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
}
