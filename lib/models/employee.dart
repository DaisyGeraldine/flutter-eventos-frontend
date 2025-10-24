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
