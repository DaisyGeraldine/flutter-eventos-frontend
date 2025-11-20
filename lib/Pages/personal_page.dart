import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/employee.dart';
// import 'package:flutter_application_2/models/empleado.dart';
import 'package:flutter_application_2/service/personal_service.dart';
import 'package:flutter_application_2/Pages/empleado_form_page.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage>
    with TickerProviderStateMixin {
  final PersonalService _personalService = PersonalService();
  List<EmployeeComplete> _empleados = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterEstado = 'Todos';
  String _filterCategoria = 'Todas';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEmployees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _personalService.getAllEmpleados();

    if (result.success && result.data != null) {
      setState(() {
        _empleados = result.data!;
      });
    } else {
      _showSnackBar(result.message, Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  List<EmployeeComplete> get _filteredEmpleados {
    List<EmployeeComplete> filtered = _empleados;

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((empleado) {
            return empleado.dni.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                empleado.nombreCompleto.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (empleado.email?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false);
          }).toList();
    }

    // Filtrar por estado
    if (_filterEstado != 'Todos') {
      final estado = EstadoEmpleado.values.firstWhere(
        (e) => e.name == _filterEstado.toLowerCase(),
        orElse: () => EstadoEmpleado.disponible,
      );
      filtered = filtered.where((e) => e.estado == estado).toList();
    }

    // Filtrar por categoría
    if (_filterCategoria != 'Todas') {
      final categoria = CategoriaPersona.values.firstWhere(
        (c) => c.name == _filterCategoria.toLowerCase(),
        orElse: () => CategoriaPersona.mozo,
      );
      filtered =
          filtered.where((e) => e.categoriaPersona == categoria).toList();
    }

    return filtered;
  }

  List<EmployeeComplete> get _empleadosDisponibles {
    return _empleados
        .where((e) => e.estado == EstadoEmpleado.disponible)
        .toList();
  }

  List<EmployeeComplete> get _empleadosEnEvento {
    return _empleados
        .where((e) => e.estado == EstadoEmpleado.enEvento)
        .toList();
  }

  Future<void> _deleteEmpleado(EmployeeComplete empleado) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Empleado'),
            content: Text(
              '¿Estás seguro de que quieres eliminar a ${empleado.nombreCompleto}?\nEsta acción eliminará tanto los datos de persona como de empleado.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final result = await _personalService.deleteEmpleado(empleado.dni);

      if (result.success) {
        _showSnackBar('Empleado eliminado exitosamente', Colors.green);
        _loadEmployees();
      } else {
        _showSnackBar(result.message, Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Personal'),
        backgroundColor: const Color(0xff142047),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Todos', icon: Icon(Icons.people)),
            Tab(text: 'Disponibles', icon: Icon(Icons.check_circle)),
            Tab(text: 'En Evento', icon: Icon(Icons.event_busy)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          _buildSearchAndFilters(),
          // Contenido de tabs
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEmpleadosList(_filteredEmpleados),
                        _buildEmpleadosList(_empleadosDisponibles),
                        _buildEmpleadosList(_empleadosEnEvento),
                      ],
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const EmpleadoFormPage()),
          );

          if (result == true) {
            _loadEmployees();
          }
        },
        backgroundColor: const Color(0xff142047),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por DNI, nombre o email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Filtros
          Row(
            children: [
              // Filtro por estado
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  value: _filterEstado,
                  items:
                      [
                        'Todos',
                        ...EstadoEmpleado.values.map((e) => e.name),
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _filterEstado = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Filtro por categoría
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  value: _filterCategoria,
                  items:
                      [
                        'Todas',
                        ...CategoriaPersona.values.map((c) => c.name),
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _filterCategoria = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpleadosList(List<EmployeeComplete> employees) {
    if (employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay empleados',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los empleados aparecerán aquí cuando se registren',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return _buildEmpleadoCard(employee);
        },
      ),
    );
  }

  Widget _buildEmpleadoCard(EmployeeComplete empleado) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con foto y información principal
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: empleado.categoriaColor.withOpacity(0.1),
                  child: Text(
                    empleado.nombre?.isNotEmpty == true
                        ? empleado.nombre![0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: empleado.categoriaColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        empleado.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: empleado.categoriaColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: empleado.categoriaColor,
                              ),
                            ),
                            child: Text(
                              empleado.categoriaTexto,
                              style: TextStyle(
                                color: empleado.categoriaColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: empleado.estadoColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: empleado.estadoColor),
                            ),
                            child: Text(
                              empleado.estadoTexto,
                              style: TextStyle(
                                color: empleado.estadoColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Menú de acciones
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EmpleadoFormPage(empleado: empleado),
                        ),
                      );

                      if (result == true) {
                        _loadEmployees();
                      }
                    } else if (value == 'delete') {
                      _deleteEmpleado(empleado);
                    } else if (value == 'change_estado') {
                      _showChangeEstadoDialog(empleado);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'change_estado',
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Cambiar Estado'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Información adicional
            Row(
              children: [
                if (empleado.dni.isNotEmpty) ...[
                  const Icon(Icons.badge, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'DNI: ${empleado.dni}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                ],
                if (empleado.telefono != null) ...[
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    empleado.telefono!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
            if (empleado.email != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      empleado.email!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showChangeEstadoDialog(EmployeeComplete empleado) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cambiar Estado - ${empleado.nombreCompleto}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  EstadoEmpleado.values.map((estado) {
                    return ListTile(
                      title: Text(estado.name),
                      leading: Icon(
                        Icons.circle,
                        color: _getColorForEstado(estado),
                      ),
                      selected: estado == empleado.estado,
                      onTap: () async {
                        Navigator.of(context).pop();
                        if (estado != empleado.estado) {
                          final result = await _personalService
                              .updateEstadoEmpleado(empleado.dni, estado);

                          if (result.success) {
                            _showSnackBar(
                              'Estado actualizado exitosamente',
                              Colors.green,
                            );
                            _loadEmployees();
                          } else {
                            _showSnackBar(result.message, Colors.red);
                          }
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  Color _getColorForEstado(EstadoEmpleado estado) {
    switch (estado) {
      case EstadoEmpleado.disponible:
        return Colors.green;
      case EstadoEmpleado.deBaja:
        return Colors.red;
      case EstadoEmpleado.enEvento:
        return Colors.blue;
      case EstadoEmpleado.vacaciones:
        return Colors.orange;
      case EstadoEmpleado.reservado:
        return Colors.purple;
    }
  }
}
