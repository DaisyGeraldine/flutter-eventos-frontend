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

class Materials {
  final String cod;
  final String descripcion;
  final double? precio;
  // final DateTime fechaAmortizacion;
  final String? estado;
  final String? empresaProveedora;

  Materials({
    required this.cod,
    required this.descripcion,
    required this.precio,
    // required this.fechaAmortizacion,
    required this.estado,
    required this.empresaProveedora,
  });

  factory Materials.fromJson(Map<String, dynamic> json) {
    return Materials(
      cod: json['cod'],
      descripcion: json['descripcion'],
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
      'precio': precio,
      // 'fechaAmortizacion': fechaAmortizacion.toIso8601String(),
      'estado': estado,
      'empresaProveedora': empresaProveedora,
    };
  }
}
