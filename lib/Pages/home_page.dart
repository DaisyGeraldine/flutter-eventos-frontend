import 'package:flutter/material.dart';
import 'package:flutter_application_2/Pages/event_detail_page.dart';
import 'package:flutter_application_2/models/employee.dart';
import 'package:flutter_application_2/models/event.dart';
import 'package:flutter_application_2/service/personal_service.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final String dni;
  const HomePage({Key? key, required this.dni}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final EmployeeService _employeeService = EmployeeService();
  final PersonalService _personalService = PersonalService();
  final employee = Employee();
  List<Event> _upcomingEvents = [];
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

    // DrawerItem(
    //   Icons.assignment,
    //   'Tareas',
    //   '/tareas',
    //   gerente: true,
    //   limitados: true,
    // ),
    DrawerItem(
      Icons.access_time,
      'Horas trabajadas',
      '/horas',
      gerente: true,
      todos: true,
    ),
    DrawerItem(Icons.event, 'Gestión Eventos', '/eventos', gerente: true),
    // DrawerItem(Icons.message, 'Mensajes', '/mensajes', gerente: true),
  ];

  @override
  void initState() {
    super.initState();
    loadEmployeeData();
  }

  void loadEmployeeData() async {
    setState(() => isLoading = true);

    try {
      final result = await _personalService.getAllEmpleados();

      if (result.success && result.data != null) {
        // result.data puede contener objetos dinámicos (Map) o modelos
        for (final item in result.data!) {
          if (item == null) continue;
          if (item is! Employee) continue; // evitar tipos inesperados

          final e = item as Employee;
          if ((e.dni ?? '') == widget.dni) {
            // Asignar solo campos relevantes (añade los que necesites)
            employee.dni = e.dni ?? employee.dni;
            employee.nombre = e.nombre ?? employee.nombre;
            employee.apellidos = e.apellidos ?? employee.apellidos;
            employee.categoriaPersona =
                e.categoriaPersona ?? employee.categoriaPersona;
            employee.estado = e.estado ?? employee.estado;
            employee.email = e.email ?? employee.email;
            employee.telefono = e.telefono ?? employee.telefono;
            employee.numSS = e.numSS ?? employee.numSS;
            employee.contratosHoras =
                e.contratosHoras ?? employee.contratosHoras;
            // si tienes otros campos (ej. fechaAlta) añádelos aquí

            break;
          }
        }
      }

      // después de cargar employee, cargar próximos eventos del empleado
      final eventsResult = await _personalService.getUpcomingEventsForEmpleado(
        widget.dni,
      );
      if (eventsResult.success && eventsResult.data != null) {
        setState(() => _upcomingEvents = eventsResult.data!);
      }
    } catch (e) {
      // no mostrar error intrusivo aquí
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        (employee.nombre?.isNotEmpty == true ||
                employee.apellidos?.isNotEmpty == true)
            ? '${employee.nombre ?? ''} ${employee.apellidos ?? ''}'.trim()
            : widget.dni;

    return Scaffold(
      appBar: AppBar(
        title: Text('Panel'),
        backgroundColor: const Color(0xff142047),
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
                  children: <Widget>[
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.blueGrey[50],
                              child: Text(
                                (employee.nombre?.isNotEmpty == true)
                                    ? employee.nombre![0].toUpperCase()
                                    : widget.dni[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¡Bienvenido, $displayName!',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    employee.categoriaPersona
                                            ?.toString()
                                            .toUpperCase() ??
                                        (employee.categoriaPersona ?? ''),
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (employee.email != null &&
                                          employee.email!.isNotEmpty) ...[
                                        const Icon(
                                          Icons.email,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            employee.email!,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      if (employee.telefono != null &&
                                          employee.telefono!.isNotEmpty) ...[
                                        const Icon(
                                          Icons.phone,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          employee.telefono!,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          employee.estado?.toUpperCase() ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                                  Text(
                                    employee.contratosHoras?.toString() ?? '—',
                                    style: const TextStyle(
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
                        // Expanded(
                        //   child: Card(
                        //     color: Colors.orange[50],
                        //     elevation: 2,
                        //     child: Padding(
                        //       padding: const EdgeInsets.symmetric(vertical: 16),
                        //       child: Column(
                        //         children: [
                        //           Icon(
                        //             Icons.event,
                        //             color: Colors.orange,
                        //             size: 32,
                        //           ),
                        //           SizedBox(height: 6),
                        //           Text(
                        //             'Próximos eventos',
                        //             style: TextStyle(
                        //               fontWeight: FontWeight.bold,
                        //             ),
                        //           ),
                        //           const SizedBox(height: 4),
                        //           Text(
                        //             "",
                        //             // employee.proximosEventos?.toString() ?? '—',
                        //             style: const TextStyle(
                        //               fontSize: 18,
                        //               color: Colors.orange,
                        //             ),
                        //           ),
                        //           // Ejemplo: int proximosEventosTotal = 3;
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            color: Colors.green[50],
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.badge,
                                    color: Colors.green,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Contrato / Rol',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    employee.numSS ??
                                        (employee.categoriaPersona ?? '—'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Próximos eventos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_upcomingEvents.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Text(
                                  'No hay eventos asignados próximamente.',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                            else
                              Column(
                                children:
                                    _upcomingEvents.map((ev) {
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(
                                          Icons.event,
                                          color: Colors.orange,
                                        ),
                                        title: Text(ev.nombre ?? ev.cod),
                                        subtitle: Text(
                                          '${DateFormat('dd/MM/yyyy').format(ev.fechaIni)} • ${ev.direccion ?? ''}',
                                        ),
                                        trailing: Icon(Icons.chevron_right),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => EventDetailPage(
                                                    event: ev,
                                                  ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                              ),
                          ],
                        ),
                      ),
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
      accountName: Text(
        '${employee.nombre ?? ''} ${employee.apellidos ?? ''}'.trim(),
      ),
      accountEmail: Text(
        employee.categoriaPersona?.toString().toUpperCase() ??
            (employee.categoriaPersona ?? ''),
      ),
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
