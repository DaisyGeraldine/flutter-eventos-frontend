import 'dart:convert';

import 'package:flutter_application_2/models/event.dart';
import 'package:flutter_application_2/models/request_event.dart';
import 'package:http/http.dart' as http;

class EventService {
  static const String _baseUrl = 'http://localhost:3000/api';

  Future<List<Event>> getEvents() async {
    String url = "$_baseUrl/events";
    print('Solicitando eventos a: $url');
    //try {
    final response = await http
        .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 10));
    print(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final eventsData = data['data'] as List;
      print('Eventos recibidos: ${eventsData.length}');
      print('Datos del Evento: $eventsData');

      return eventsData.map((eventJson) => Event.fromJson(eventJson)).toList();
    } else {
      print('Error en la respuesta: ${response.statusCode}');
      throw Exception('Error al cargar eventos: ${response.statusCode}');
    }
    //} catch (e) {
    //  print('Excepción en getEvents: $e');
    //  throw Exception('Error de conexión: $e');
    //}
  }

  Future<List<Event>> getEventsByEmployee(String dni) async {
    String url = "$_baseUrl/events/employee";
    Map<String, dynamic> body = {'dni': dni};
    print('Solicitando eventos para el empleado con DNI $dni a: $url');
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final eventsData = data['data'] as List;
        print(
          'Eventos recibidos para el empleado con DNI $dni: ${eventsData.length}',
        );
        print('Datos del Evento: $eventsData');

        return eventsData
            .map((eventJson) => Event.fromJson(eventJson))
            .toList();
      } else {
        print('Error en la respuesta: ${response.statusCode}');
        throw Exception(
          'Error al cargar eventos para el empleado: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Excepción en getEventsByEmployee: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<RequestEvent>> getRequestEvents() async {
    String url = "$_baseUrl/events/requestEvents";
    print('Solicitando eventos de solicitud a: $url');
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final requestEventsData = data['data'] as List;
        print('Eventos de solicitud recibidos: ${requestEventsData.length}');
        print('Datos del Evento de Solicitud: $requestEventsData');

        return requestEventsData
            .map((eventJson) => RequestEvent.fromJson(eventJson))
            .toList();
      } else {
        print('Error en la respuesta: ${response.statusCode}');
        throw Exception(
          'Error al cargar eventos de solicitud: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Excepción en getRequestEvents: $e');
      throw Exception('Error de conexión: $e');
    }
  }


}
