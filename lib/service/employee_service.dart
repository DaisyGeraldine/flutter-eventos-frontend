import 'dart:convert';

import 'package:flutter_application_2/models/employee.dart';
import 'package:http/http.dart' as http;

class EmployeeService {
  static const String _baseUrl = 'http://localhost:3000/api';

  Future<void> getEmployeeById(String dni) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/employee/data/$dni'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    print('Respuesta recibida. Código: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print('Datos del empleado: $data');

      Employee().fromJson(data['data']);

      print("Modelo cargado: ${Employee().toJson()}");

      return;
    } else {
      print('Error al obtener el empleado: ${response.statusCode}');
      return;
    }
  }

  Future<List<Employee>> getAllEmployees() async {
    String url = "$_baseUrl/employee/list";
    print('Solicitando empleados a: $url');
    final response = await http
        .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 10));

    print('Respuesta recibida. Código: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Empleados recibidos: ${data['data'].length}');
      print('Datos de los empleados: $data');

      final employeesData = data['data'] as List;

      final employeeJson =
          employeesData
              .map((employeeJson) => Employee.fromJson(employeeJson))
              .toList();

      for (var employee = 0; employee < employeeJson.length; employee++) {
        print('Empleado $employee: ${employeeJson[employee].toJson()}');
      }

      return employeeJson;
    } else {
      print('Error al obtener los empleados: ${response.statusCode}');
      throw Exception('Error al cargar empleados: ${response.statusCode}');
    }
  }
}
