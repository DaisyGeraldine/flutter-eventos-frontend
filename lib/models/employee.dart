class Employee {
  static final Employee _instance = Employee._internal();

  String? dni;
  String? nombre;
  String? apellidos;
  String? numSS;
  String? categoria; // 'gerente', 'organizacion', 'mozo', 'tecnico', 'almacen'
  String? email;
  String? estado;

  // Constructor para otros empleados
  Employee.newInstance();

  factory Employee() {
    return _instance;
  }

  bool get esGerente => categoria == 'gerente';
  bool get esOrganizacion => categoria == 'organización';
  bool get esRolLimitado => !esGerente && !esOrganizacion;

  void fromJson(Map<String, dynamic> json) {
    dni = json['dni'];
    nombre = json['nombre'];
    apellidos = json['apellidos'];
    numSS = json['numSS'];
    categoria = json['categoria'];
    email = json['email'];
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
      'dni': this.dni,
      'nombre': this.nombre,
      'apellidos': this.apellidos,
      'numSS': this.numSS,
      'categoria': this.categoria,
      'email': this.email,
      'estado':
          this.estado ?? 'disponible', // Default to 'disponible' if not set
    };
  }

  Employee._internal();
}
