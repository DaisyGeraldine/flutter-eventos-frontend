import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/persona.dart';

enum CategoriaPersona { gerente, organizacion, encargadoAlmacen, tecnicoLuces, tecnicoSonido, mozo }

enum EstadoEmpleado { disponible, deBaja, enEvento, vacaciones, reservado }

class EmployeeComplete extends Persona {
  final String? numSS;
  final CategoriaPersona? categoriaPersona;
  final int? contratosHoras;
  final DateTime? fechaAlta;
  final EstadoEmpleado? estado;
  final String? email;
  final String? contrasena;
  final String? telefono;

  EmployeeComplete({
    required String dni,
    String? nombre,
    String? apellidos,
    String? direccion,
    this.numSS,
    this.categoriaPersona,
    this.contratosHoras,
    this.fechaAlta,
    this.estado,
    this.email,
    this.contrasena,
    this.telefono,
  }) : super(
          dni: dni,
          nombre: nombre,
          apellidos: apellidos,
          direccion: direccion,
        );

  bool get esGerente => categoriaPersona == CategoriaPersona.gerente;
  bool get esOrganizacion => categoriaPersona == CategoriaPersona.organizacion;
  bool get esRolLimitado => !esGerente && !esOrganizacion;

  factory EmployeeComplete.fromJson(Map<String, dynamic> json) {
    return EmployeeComplete(
      dni: json['dni'] ?? '',
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      direccion: json['direccion'],
      numSS: json['numSS'],
      categoriaPersona: json['categoriaPersona'] != null
          ? CategoriaPersona.values.firstWhere(
              (e) => e.name == json['categoriaPersona'],
              orElse: () => CategoriaPersona.mozo,
            )
          : null,
      contratosHoras: json['contratosHoras'],
      fechaAlta: json['fechaAlta'] != null ? DateTime.parse(json['fechaAlta']) : null,
      estado: json['estado'] != null
          ? EstadoEmpleado.values.firstWhere(
              (e) => e.name == json['estado'],
              orElse: () => EstadoEmpleado.disponible,
            )
          : null,
      email: json['email'],
      contrasena: json['contrasena'],
      telefono: json['telefono'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dni': dni,
      'nombre': nombre,
      'apellidos': apellidos,
      'direccion': direccion,
      'numSS': numSS,
      'categoriaPersona': categoriaPersona?.name,
      'contratosHoras': contratosHoras,
      'fechaAlta': fechaAlta?.toIso8601String().split('T')[0],
      'estado': estado?.name,
      'email': email,
      'contrasena': contrasena,
      'telefono': telefono,
    };
  }

  Map<String, dynamic> toPersonaJson() {
    return {
      'dni': dni,
      'nombre': nombre,
      'apellidos': apellidos,
      'direccion': direccion,
    };
  }

  Map<String, dynamic> toEmpleadoJson() {
    return {
      'dni': dni,
      'numSS': numSS,
      'categoriaPersona': categoriaPersona?.name,
      'contratosHoras': contratosHoras,
      'fechaAlta': fechaAlta?.toIso8601String().split('T')[0],
      'estado': estado?.name,
      'email': email,
      'contrasena': contrasena,
      'telefono': telefono,
    };
  }

  String get categoriaTexto {
    switch (categoriaPersona) {
      case CategoriaPersona.gerente:
        return 'Gerente';
      case CategoriaPersona.organizacion:
        return 'Organización';
      case CategoriaPersona.encargadoAlmacen:
        return 'Encargado de Almacén';
      case CategoriaPersona.tecnicoLuces:
        return 'Técnico de Luces';
      case CategoriaPersona.tecnicoSonido:
        return 'Técnico de Sonido';
      case CategoriaPersona.mozo:
        return 'Mozo';
      default:
        return 'Sin categoría';
    }
  }

  String get estadoTexto {
    switch (estado) {
      case EstadoEmpleado.disponible:
        return 'Disponible';
      case EstadoEmpleado.deBaja:
        return 'De Baja';
      case EstadoEmpleado.enEvento:
        return 'En Evento';
      case EstadoEmpleado.vacaciones:
        return 'Vacaciones';
      case EstadoEmpleado.reservado:
        return 'Reservado';
      default:
        return 'Sin estado';
    }
  }

  Color get estadoColor {
    switch (estado) {
      case EstadoEmpleado.disponible:
        return Colors.green;
      case EstadoEmpleado.deBaja:
        return Colors.red;
      case EstadoEmpleado.enEvento:
        return Colors.blue;
      case EstadoEmpleado.vacaciones:
        return Colors.orange;
      case EstadoEmpleado.reservado:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color get categoriaColor {
    switch (categoriaPersona) {
      case CategoriaPersona.gerente:
        return Colors.purple;
      case CategoriaPersona.organizacion:
        return Colors.blue;
      case CategoriaPersona.encargadoAlmacen:
        return Colors.green;
      case CategoriaPersona.tecnicoLuces:
        return Colors.yellow[700]!;
      case CategoriaPersona.tecnicoSonido:
        return Colors.orange;
      case CategoriaPersona.mozo:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  EmployeeComplete copyWith({
    String? dni,
    String? nombre,
    String? apellidos,
    String? direccion,
    String? numSS,
    CategoriaPersona? categoriaPersona,
    int? contratosHoras,
    DateTime? fechaAlta,
    EstadoEmpleado? estado,
    String? email,
    String? contrasena,
    String? telefono,
  }) {
    return EmployeeComplete(
      dni: dni ?? this.dni,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      direccion: direccion ?? this.direccion,
      numSS: numSS ?? this.numSS,
      categoriaPersona: categoriaPersona ?? this.categoriaPersona,
      contratosHoras: contratosHoras ?? this.contratosHoras,
      fechaAlta: fechaAlta ?? this.fechaAlta,
      estado: estado ?? this.estado,
      email: email ?? this.email,
      contrasena: contrasena ?? this.contrasena,
      telefono: telefono ?? this.telefono,
    );
  }
}

class Employee {
  static final Employee _instance = Employee._internal();

  String? dni;
  String? nombre;
  String? apellidos;
  String? direccion;
  String? numSS;
  String?
  categoriaPersona; // 'gerente', 'organizacion', 'encargadoAlmacen', 'mozo', 'tecnicoLuces', 'tecnicoSonido'
  int? contratosHoras;
  DateTime? fechaAlta;
  String? estado;
  String? email;
  String? telefono;

  // Constructor para otros empleados
  Employee.newInstance();

  factory Employee() {
    return _instance;
  }

  bool get esGerente => categoriaPersona == 'gerente';
  bool get esOrganizacion => categoriaPersona == 'organización';
  bool get esRolLimitado => !esGerente && !esOrganizacion;

  void fromJson(Map<String, dynamic> json) {
    dni = json['dni'];
    nombre = json['nombre'];
    apellidos = json['apellidos'];
    direccion = json['direccion'];
    numSS = json['numSS'];
    categoriaPersona = json['categoriaPersona'];
    email = json['email'];
    telefono = json['telefono'];
    contratosHoras = json['contratosHoras'];
    fechaAlta = DateTime.parse(json['fechaAlta']);
    estado =
        json['estado'] ??
        'disponible'; // Default to 'disponible' if not provided
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    final emp = Employee.newInstance();
    emp.fromJson(json);
    return emp;
  }

  Map<String, dynamic> toJson() {
    return {
      'dni': dni,
      'nombre': nombre,
      'apellidos': apellidos,
      'numSS': numSS,
      'categoriaPersona': categoriaPersona,
      'email': email,
      'estado': estado ?? 'disponible', // Default to 'disponible' if not set
      'telefono': telefono,
      'contratosHoras': contratosHoras,
      'fechaAlta': fechaAlta?.toIso8601String(),
    };
  }

  Employee._internal();
}
