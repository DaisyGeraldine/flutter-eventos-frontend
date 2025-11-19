import 'package:flutter/material.dart';

class Event {
  final String cod;
  final String nombre;
  final String descripcionMaterial;
  final String descripcionPersonal;
  final DateTime fechaIni;
  final DateTime fechaFin;
  // final TimeOfDay horaPrevistaIni;
  final double duracion;
  final String direccion;
  final int aforo;
  final int m2;
  final String? anotaciones;
  // final double presupuestoInicial;
  // final double presupuestoModificado;
  final String dniUsuario;
  final String nombreUsuario;
  final TimeOfDay? horaPrevistaInicio;
  final double? presupuesto;
  final double? presupuestoModificado;
  final String? estado;

  Event({
    required this.cod,
    required this.nombre,
    required this.descripcionMaterial,
    required this.descripcionPersonal,
    required this.fechaIni,
    required this.fechaFin,
    // required this.horaPrevistaIni,
    required this.duracion,
    required this.direccion,
    required this.aforo,
    required this.m2,
    required this.anotaciones,
    // required this.presupuestoInicial,
    // required this.presupuestoModificado,
    required this.dniUsuario,
    required this.nombreUsuario,
    required this.horaPrevistaInicio,
    required this.presupuesto,
    required this.presupuestoModificado,
    required this.estado,
  });

  // Convert event to JSON
  Map<String, dynamic> toJson() {
    return {
      'cod': cod,
      'nombre': nombre,
      'descripcionMaterial': descripcionMaterial,
      'descripcionPersonal': descripcionPersonal,
      'fechaIni': fechaIni.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      // 'horaPrevistaIni': '${horaPrevistaIni.hour}:${horaPrevistaIni.minute}',
      'duracion': duracion,
      'direccion': direccion,
      'aforo': aforo,
      'm2': m2,
      'anotaciones': anotaciones,
      // 'presupuestoInicial': presupuestoInicial,
      // 'presupuestoModificado': presupuestoModificado,
      'dniUsuario': dniUsuario,
      'nombreUsuario': nombreUsuario,
      'horaPrevistaInicio': horaPrevistaInicio,
      'presupuesto': presupuesto,
      'presupuestoModificado': presupuestoModificado,
      'estado': estado,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    // Parsea la hora de un string "HH:mm"
    final timeParts;
    if (json['horaPrevistaInicio'] != null && json['horaPrevistaInicio'] is String) {
      timeParts = (json['horaPrevistaInicio'] as String).split(':');
    } else {
      timeParts = ['0', '0'];
    }

    return Event(
      cod: json['cod'],
      nombre: json['nombre'],
      descripcionMaterial: json['descripcionMaterial'] ?? '',
      descripcionPersonal: json['descripcionPersonal'] ?? '',
      fechaIni: DateTime.parse(json['fechaIni']),
      fechaFin: DateTime.parse(json['fechaFin']),
      // horaPrevistaIni: TimeOfDay(
      //   hour: int.parse(timeParts[0]),
      //   minute: int.parse(timeParts[1]),
      // ),
      duracion: json['duracion'].toDouble() ?? 0.0,
      direccion: json['direccion'] ?? '',
      aforo: json['aforo'] ?? 0,
      m2: json['m2'] ?? 0,
      anotaciones: json['anotaciones'] ?? '',
      // presupuestoInicial: json['presupuestoInicial'].toDouble(),
      // presupuestoModificado: json['presupuestoModificado'].toDouble(),
      dniUsuario: json['dniUsuario'],
      nombreUsuario: json['nombreUsuario'],
      horaPrevistaInicio: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      presupuesto: json['presupuesto']?.toDouble() ?? 0.0,
      presupuestoModificado: json['presupuestoModificado']?.toDouble() ?? 0.0,
      estado: json['estado'] ?? '',
    );
  }
}
