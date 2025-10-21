import 'dart:convert';

import 'package:flutter_application_2/models/own_material.dart';
import 'package:http/http.dart' as http;

class MaterialService {
  static const String _baseUrl = 'http://localhost:3000/api';

  // Aquí puedes definir los métodos y propiedades de tu servicio
  Future<List<OwnMaterial>> fetchMaterials() async {
    String url = "$_baseUrl/materials";
    print('Solicitando materiales a: $url');

    final response = await http
        .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 10));

    print('Respuesta recibida. Código: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // final materialsData = data['data'] as List;
      // print('Materiales recibidos: ${data.length}');
      // print('Datos de Material: $data');
      final List<dynamic> materialsData = data['data'] ?? [];
      print('Materiales recibidos: ${materialsData.length}');
      print('Datos de Material: $materialsData');
      List<OwnMaterial> materialData =
          materialsData
              .map((materialJson) => OwnMaterial.fromJson(materialJson))
              .toList();
      return materialData;
    } else {
      print('Error en la respuesta: ${response.statusCode}');
      throw Exception('Error al cargar materiales');
    }
  }

  Future<void> createMaterial(OwnMaterial material) async {
    String url = "$_baseUrl/materials";
    print('Creando material en: $url');

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(material.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      print('Material creado exitosamente');
    } else {
      print('Error en la creación del material: ${response.statusCode}');
      throw Exception('Error al crear material');
    }
  }

  Future<void> updateMaterial(OwnMaterial material) async {
    String url = "$_baseUrl/materials/${material.cod}";
    print('Actualizando material en: $url');

    final response = await http
        .put(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(material.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      print('Material actualizado exitosamente');
    } else {
      print('Error en la actualización del material: ${response.statusCode}');
      throw Exception('Error al actualizar material');
    }
  }

  Future<void> deleteMaterial(String id) async {
    String url = "$_baseUrl/materials/$id";
    print('Eliminando material en: $url');

    final response = await http
        .delete(Uri.parse(url), headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      print('Material eliminado exitosamente');
    } else {
      print('Error en la eliminación del material: ${response.statusCode}');
      throw Exception('Error al eliminar material');
    }
  }
}
