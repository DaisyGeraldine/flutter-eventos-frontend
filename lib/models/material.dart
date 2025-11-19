// class OwnMaterial {
//   final String cod;
//   final String descripcion;
//   final double precio;
//   final DateTime fechaAmortizacion;
//   final String estado;

//   OwnMaterial({
//     required this.cod,
//     required this.descripcion,
//     required this.precio,
//     required this.fechaAmortizacion,
//     required this.estado,
//   });

//   factory OwnMaterial.fromJson(Map<String, dynamic> json) {
//     return OwnMaterial(
//       cod: json['cod'],
//       descripcion: json['descripcion'],
//       precio:
//           json['precio'] is int
//               ? (json['precio'] as int).toDouble()
//               : json['precio'].toDouble(),
//       fechaAmortizacion: DateTime.parse(json['fechaAmortizacion']),
//       estado: json['estado'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'cod': cod,
//       'descripcion': descripcion,
//       'precio': precio,
//       'fechaAmortizacion': fechaAmortizacion.toIso8601String(),
//       'estado': estado,
//     };
//   }
// }

import 'package:flutter/material.dart';

class Materials {
  final String cod;
  final String? descripcion;
  final DateTime? fechaIni;
  final DateTime? fechaFin;
  final double? precio;
  // final DateTime fechaAmortizacion;
  final String? estado;
  final String? empresaProveedora;

  Materials({
    required this.cod,
    required this.descripcion,
    this.fechaIni,
    this.fechaFin,
    this.precio,
    // required this.fechaAmortizacion,
    required this.estado,
    required this.empresaProveedora,
  });

  factory Materials.fromJson(Map<String, dynamic> json) {
    return Materials(
      cod: json['cod'],
      descripcion: json['descripcion'],
      fechaIni: json['fechaIni'] != null ? DateTime.parse(json['fechaIni']) : null,
      fechaFin: json['fechaFin'] != null ? DateTime.parse(json['fechaFin']) : null,
      precio:
          json['precio'] != null
              ? (json['precio'] is int
                  ? (json['precio'] as int).toDouble()
                  : json['precio'].toDouble())
              : null,
      // fechaAmortizacion: DateTime.parse(json['fechaAmortizacion']),
      estado: json['estado'] != null ? json['estado'] : null,
      empresaProveedora:
          json['empresaProveedora'] != null ? json['empresaProveedora'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cod': cod,
      'descripcion': descripcion,
      'fechaIni': fechaIni?.toIso8601String().split('T')[0],
      'fechaFin': fechaFin?.toIso8601String().split('T')[0],
      'precio': precio,
      // 'fechaAmortizacion': fechaAmortizacion.toIso8601String(),
      'estado': estado,
      'empresaProveedora': empresaProveedora,
    };
  }

  Materials copyWith({
    String? cod,
    String? descripcion,
    DateTime? fechaIni,
    DateTime? fechaFin,
    double? precio,
    String? estado,
    String? empresaProveedora,
  }) {
    return Materials(
      cod: cod ?? this.cod,
      descripcion: descripcion ?? this.descripcion,
      fechaIni: fechaIni ?? this.fechaIni,
      fechaFin: fechaFin ?? this.fechaFin,
      precio: precio ?? this.precio,
      estado: estado ?? this.estado,
      empresaProveedora: empresaProveedora ?? this.empresaProveedora,
    );
  }
}

enum EstadoMaterial { alquilado, reservado, enUso, averiado, disponible }

class MaterialEnInventario {
  final String cod;
  final EstadoMaterial estado;
  final DateTime? fechaFabricacion;
  final DateTime? diasDisponibilidad;

  MaterialEnInventario({
    required this.cod,
    required this.estado,
    this.fechaFabricacion,
    this.diasDisponibilidad,
  });

  factory MaterialEnInventario.fromJson(Map<String, dynamic> json) {
    return MaterialEnInventario(
      cod: json['cod'] ?? '',
      estado: EstadoMaterial.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoMaterial.disponible,
      ),
      fechaFabricacion: json['fechaFabricacion'] != null 
        ? DateTime.parse(json['fechaFabricacion']) 
        : null,
      diasDisponibilidad: json['diasDisponibilidad'] != null 
        ? DateTime.parse(json['diasDisponibilidad']) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cod': cod,
      'estado': estado.name,
      'fechaFabricacion': fechaFabricacion?.toIso8601String().split('T')[0],
      'diasDisponibilidad': diasDisponibilidad?.toIso8601String().split('T')[0],
    };
  }

  String get estadoTexto {
    switch (estado) {
      case EstadoMaterial.alquilado:
        return 'Alquilado';
      case EstadoMaterial.reservado:
        return 'Reservado';
      case EstadoMaterial.enUso:
        return 'En Uso';
      case EstadoMaterial.averiado:
        return 'Averiado';
      case EstadoMaterial.disponible:
        return 'Disponible';
    }
  }

  Color get estadoColor {
    switch (estado) {
      case EstadoMaterial.alquilado:
        return Colors.orange;
      case EstadoMaterial.reservado:
        return Colors.blue;
      case EstadoMaterial.enUso:
        return Colors.purple;
      case EstadoMaterial.averiado:
        return Colors.red;
      case EstadoMaterial.disponible:
        return Colors.green;
    }
  }
}
