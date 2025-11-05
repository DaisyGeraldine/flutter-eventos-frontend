class Personal {
  final String dni;
  final String nombre;
  final String apellidos;
  final String category;
  final double? precio;

  Personal({
    required this.dni,
    required this.nombre,
    required this.apellidos,
    required this.category,
    required this.precio,
  });

  factory Personal.fromJson(Map<String, dynamic> json) {
    return Personal(
      dni: json['dni'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      category: json['category'],
      precio:
          json['precio'] != null ? (json['precio'] as num).toDouble() : null,
    );
  }
}
