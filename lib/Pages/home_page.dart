import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/employee.dart';

class HomePage extends StatefulWidget {
  final String dni;
  const HomePage({Key? key, required this.dni}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final EmployeeService _employeeService = EmployeeService();
  final employee = Employee();
  bool isLoading = false;

  final List<DrawerItem> _todasOpciones = [
    DrawerItem(Icons.calendar_today, 'Calendario', '/calendario', todos: true),
    DrawerItem(
      Icons.inventory,
      'Almacén',
      '/almacen',
      gerente: true,
      todos: true,
    ),
    DrawerItem(
      Icons.people,
      'Personal',
      '/personal',
      gerente: true,
      organizacion: true,
    ),

    DrawerItem(
      Icons.assignment,
      'Tareas',
      '/tareas',
      gerente: true,
      limitados: true,
    ),
    DrawerItem(
      Icons.access_time,
      'Horas trabajadas',
      '/horas',
      gerente: true,
      todos: true,
    ),
    DrawerItem(Icons.event, 'Gestión Eventos', '/eventos', gerente: true),
    DrawerItem(Icons.message, 'Mensajes', '/mensajes', gerente: true),
  ];

  @override
  void initState() {
    super.initState();
    loadEmployeeData();
  }

  void loadEmployeeData() async {
    isLoading = true;
    try {
      //await _employeeService.getEmployeeById(widget.dni);
      print('Empleado - HomePage: ${employee.toJson()}');
    } catch (e) {
      print('Error al cargar los datos del empleado: $e');
    }
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // print('Empleado: ${employee?.toJson()}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            _buildHeader(employee),
            ..._buildMenuOptions(employee),
            Divider(),
            _buildLogoutOption(),
          ],
        ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.green,
                                  size: 32,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '¡Bienvenido, ${employee.nombre}!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Resumen de tu actividad',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Resumen visual (puedes personalizar los valores)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.blue[50],
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.blue,
                                    size: 32,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Horas trabajadas',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // TODO: Reemplaza este valor por el total real de horas trabajadas
                                  Text(
                                    "50", //horasTrabajadasTotal.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  // Ejemplo: int horasTrabajadasTotal = 120;
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            color: Colors.orange[50],
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event,
                                    color: Colors.orange,
                                    size: 32,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Próximos eventos',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // TODO: Reemplaza este valor por el total real de eventos próximos
                                  Text(
                                    "3", //proximosEventosTotal.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  // Ejemplo: int proximosEventosTotal = 3;
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            color: Colors.green[50],
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.message,
                                    color: Colors.green,
                                    size: 32,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Mensajes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // TODO: Reemplaza este valor por el total real de mensajes
                                  Text(
                                    "5", //mensajesTotal.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.green,
                                    ),
                                  ),
                                  // Ejemplo: int mensajesTotal = 5;
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  List<Widget> _buildMenuOptions(Employee employee) {
    return _todasOpciones
        .where((option) {
          if (option.todos) return true;
          if (employee.esGerente) return true;
          if (employee.esOrganizacion &&
              (option.organizacion || option.limitados))
            return true;
          if (employee.esRolLimitado && option.limitados) return true;
          return false;
        })
        .map((option) => _buildOption(option))
        .toList();
  }

  Widget _buildHeader(Employee employee) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: Color(0xff142047)),
      currentAccountPicture: CircleAvatar(
        child: Image(image: AssetImage('assets/images/logo.png')),
      ),
      accountName: Text('${employee.nombre} ${employee.apellidos}'),
      accountEmail: Text(employee.categoriaPersona?.toUpperCase() ?? ''),
    );
  }

  Widget _buildOption(DrawerItem option) {
    return ListTile(
      leading: Icon(option.icon),
      title: Text(option.text),
      onTap: () => Navigator.pushNamed(context, option.route),
    );
  }

  Widget _buildLogoutOption() {
    return ListTile(
      leading: Icon(Icons.exit_to_app),
      title: Text('Cerrar Sesión'),
      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
    );
  }
}

class DrawerItem {
  final IconData icon;
  final String text;
  final String route;
  final bool todos;
  final bool limitados;
  final bool organizacion;
  final bool gerente;

  DrawerItem(
    this.icon,
    this.text,
    this.route, {
    this.todos = false,
    this.limitados = false,
    this.organizacion = false,
    this.gerente = false,
  });
}
