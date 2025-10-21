class RequestEvent {
  final String cod;
  final String nombre;
  final String descripcionMaterial;
  final String descripcionPersonal;
  final DateTime? fechaIni;
  final DateTime? fechaFin;
  final double duracion;
  final String direccion;
  final int aforo;
  final double m2;
  final String estado;
  final double presupuesto;

  RequestEvent({
    required this.cod,
    required this.nombre,
    required this.descripcionMaterial,
    required this.descripcionPersonal,
    required this.fechaIni,
    required this.fechaFin,
    required this.duracion,
    required this.direccion,
    required this.aforo,
    required this.m2,
    required this.estado,
    required this.presupuesto,
  });

  @override
  // Convert event to JSON
  Map<String, dynamic> toJson() {
    return {
      'cod': cod,
      'nombre': nombre,
      'descripcionMaterial': descripcionMaterial,
      'descrpcionPersonal': descripcionPersonal,
      'fechaIni': fechaIni?.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'duracion': duracion,
      'direccion': direccion,
      'aforo': aforo,
      'm2': m2,
      'estado': estado,
      'presupuesto': presupuesto,
    };
  }

  factory RequestEvent.fromJson(Map<String, dynamic> json) {
    return RequestEvent(
      cod: json['cod'],
      nombre: json['nombre'],
      descripcionMaterial: json['descripcionMaterial'],
      descripcionPersonal: json['descripcionPersonal'],
      fechaIni: DateTime.tryParse(json['fechaIni']),
      fechaFin: DateTime.tryParse(json['fechaFin']),
      duracion: json['duracion'].toDouble(),
      direccion: json['direccion'],
      aforo: json['aforo'],
      m2: json['m2'].toDouble(),
      estado: json['estado'] ?? '',
      presupuesto: json['presupuesto'].toDouble(),
    );
  }
}
