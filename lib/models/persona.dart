class Persona {
  final String dni;
  final String? nombre;
  final String? apellidos;
  final String? direccion;

  Persona({
    required this.dni,
    this.nombre,
    this.apellidos,
    this.direccion,
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      dni: json['dni'] ?? '',
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      direccion: json['direccion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dni': dni,
      'nombre': nombre,
      'apellidos': apellidos,
      'direccion': direccion,
    };
  }

  Persona copyWith({
    String? dni,
    String? nombre,
    String? apellidos,
    String? direccion,
  }) {
    return Persona(
      dni: dni ?? this.dni,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      direccion: direccion ?? this.direccion,
    );
  }

  String get nombreCompleto => '${nombre ?? ''} ${apellidos ?? ''}'.trim();
}