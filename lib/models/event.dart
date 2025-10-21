import 'package:flutter/material.dart';

class Event {
  final String cod;
  final DateTime fechaIni;
  final DateTime fechaFin;
  final TimeOfDay horaPrevistaIni;
  final double coste;
  final double presupuestoInicial;
  final double presupuestoModificado;
  final String? estado;

  Event({
    required this.cod,
    required this.fechaIni,
    required this.fechaFin,
    required this.horaPrevistaIni,
    required this.coste,
    required this.presupuestoInicial,
    required this.presupuestoModificado,
    required this.estado,
  });

  // Convert event to JSON
  Map<String, dynamic> toJson() {
    return {
      'cod': cod,
      'fechaIni': fechaIni.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'horaPrevistaIni': '${horaPrevistaIni.hour}:${horaPrevistaIni.minute}',
      'coste': coste,
      'presupuestoInicial': presupuestoInicial,
      'presupuestoModificado': presupuestoModificado,
      'estado': estado,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    // Parsea la hora de un string "HH:mm"
    final timeParts = (json['horaPrevistaIni'] as String).split(':');

    return Event(
      cod: json['cod'],
      fechaIni: DateTime.parse(json['fechaIni']),
      fechaFin: DateTime.parse(json['fechafin']),
      horaPrevistaIni: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      coste: json['coste'].toDouble(),
      presupuestoInicial: json['presupuestoInicial'].toDouble(),
      presupuestoModificado: json['presupuestoModificado'].toDouble(),
      estado: json['estado'] ?? '',
    );
  }
}
