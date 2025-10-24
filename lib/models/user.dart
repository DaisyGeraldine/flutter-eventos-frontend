class User {
  final String dni;
  final String nombre;
  final String apellidos;
  final String direccion;
  final String? numSS;
  final String? categoriaPersona;
  final int? contratosHoras;
  final DateTime? fechaAlta;
  final String? estado;
  final String? email;
  final String? telefono;

  User({
    required this.dni,
    required this.nombre,
    required this.apellidos,
    required this.direccion,
    this.numSS,
    this.categoriaPersona,
    this.contratosHoras,
    this.fechaAlta,
    this.estado,
    this.email,
    this.telefono,
  });

  // Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'dni': dni,
      'nombre': nombre,
      'apellidos': apellidos,
      'direccion': direccion,
      'numSS': numSS,
      'categoria': categoriaPersona,
      'contratosHoras': contratosHoras,
      'fechaAlta': fechaAlta?.toIso8601String(),
      'estado': estado,
      'email': email,
      'telefono': telefono,
    };
  }

  // Create user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      dni: json['dni'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      direccion: json['direccion'],
      numSS: json['numSS'],
      categoriaPersona: json['categoriaPersona'],
      contratosHoras: json['contratosHoras'],
      fechaAlta: DateTime.parse(json['fechaAlta']),
      estado: json['estado'],
      email: json['email'],
      telefono: json['telefono'],
    );
  }
}
