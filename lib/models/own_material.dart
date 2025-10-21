class OwnMaterial {
  final String cod;
  final String descripcion;
  final double precio;
  final DateTime fechaAmortizacion;
  final String estado;

  OwnMaterial({
    required this.cod,
    required this.descripcion,
    required this.precio,
    required this.fechaAmortizacion,
    required this.estado,
  });

  factory OwnMaterial.fromJson(Map<String, dynamic> json) {
    return OwnMaterial(
      cod: json['cod'],
      descripcion: json['descripcion'],
      precio:
          json['precio'] is int
              ? (json['precio'] as int).toDouble()
              : json['precio'].toDouble(),
      fechaAmortizacion: DateTime.parse(json['fechaAmortizacion']),
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cod': cod,
      'descripcion': descripcion,
      'precio': precio,
      'fechaAmortizacion': fechaAmortizacion.toIso8601String(),
      'estado': estado,
    };
  }
}
