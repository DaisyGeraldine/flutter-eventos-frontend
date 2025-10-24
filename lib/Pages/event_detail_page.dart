import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/employee.dart';
import 'package:flutter_application_2/models/own_material.dart';
import 'package:flutter_application_2/models/request_event.dart';
import 'package:flutter_application_2/service/employee_service.dart';
import 'package:flutter_application_2/service/material_service.dart';
import 'package:flutter_application_2/utils/functions_date.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatefulWidget {
  final RequestEvent? requestEvent;
  const EventDetailPage({super.key, this.requestEvent});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  List<OwnMaterial> _selectedMaterials = [];
  List<Employee> _selectedEmployees = [];

  void _handleMaterialSelection(List<OwnMaterial> selected) {
    setState(() {
      _selectedMaterials = selected;
    });
  }

  void _handleEmployeeSelection(List<Employee> selected) {
    setState(() {
      _selectedEmployees = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text('Detalles del Evento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Detalles del Evento',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                border: Border.all(color: Colors.yellow[500]!),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Código', widget.requestEvent?.cod),
                    _buildInfoRow(
                      'Descripción Material',
                      widget.requestEvent?.descripcionMaterial,
                    ),
                    _buildInfoRow(
                      'Descripción Personal',
                      widget.requestEvent?.descripcionPersonal,
                    ),
                    _buildInfoRow(
                      'Fecha de Inicio',
                      formatDate(widget.requestEvent?.fechaIni),
                    ),
                    _buildInfoRow(
                      'Fecha de Fin',
                      formatDate(widget.requestEvent?.fechaFin),
                    ),
                    _buildInfoRow(
                      'Duración',
                      widget.requestEvent?.duracion.toString(),
                    ),
                    _buildInfoRow('Dirección', widget.requestEvent?.direccion),
                    _buildInfoRow(
                      'Aforo',
                      widget.requestEvent?.aforo?.toString(),
                    ),
                    _buildInfoRow(
                      'Metros cuadrados',
                      widget.requestEvent?.m2?.toString(),
                    ),
                    _buildInfoRow('Estado', widget.requestEvent?.estado),
                    _buildInfoRow(
                      'Presupuesto',
                      widget.requestEvent?.presupuesto?.toString(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Material:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: MaterialOwn(
                              onSelectionChanged: _handleMaterialSelection,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children:
                                _selectedMaterials.map((material) {
                                  return Chip(
                                    label: Text(material.descripcion),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedMaterials.remove(material);
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Personal: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: PersonalOwn(
                              onSelectionChanged: (selected) {
                                // Aquí puedes manejar la selección de personal
                              },
                              descripcionSolicitada:
                                  widget.requestEvent?.descripcionPersonal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children:
                                _selectedEmployees.map((employee) {
                                  return Chip(
                                    label: Text(employee.nombre ?? ''),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedEmployees.remove(employee);
                                      });
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Acción del botón
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0, top: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value ?? 'No disponible',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class MaterialOwn extends StatefulWidget {
  final Function(List<OwnMaterial>) onSelectionChanged;
  final String? descripcionSolicitada; // <- NUEVO campo opcional

  const MaterialOwn({
    super.key,
    required this.onSelectionChanged,
    this.descripcionSolicitada,
  });

  @override
  State<MaterialOwn> createState() => _MaterialOwnState();
}

class _MaterialOwnState extends State<MaterialOwn> {
  final MaterialService _materialService = MaterialService();
  List<OwnMaterial> _materialList = [];
  List<OwnMaterial> _selectedMaterials = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    try {
      final allMaterials = await _materialService.fetchMaterials();

      // Filtrar solo los disponibles
      final disponibles =
          allMaterials
              .where((m) => m.estado.toLowerCase() == 'disponible')
              .toList();

      setState(() {
        _materialList = disponibles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onMaterialToggle(OwnMaterial material, bool selected) {
    setState(() {
      if (selected) {
        _selectedMaterials.add(material);
      } else {
        _selectedMaterials.removeWhere((m) => m.cod == material.cod);
      }
    });
    widget.onSelectionChanged(_selectedMaterials);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) return Center(child: Text(_errorMessage));

    final referencia = widget.descripcionSolicitada?.toLowerCase() ?? '';

    return ListView.builder(
      itemCount: _materialList.length,
      itemBuilder: (context, index) {
        final material = _materialList[index];
        final isSelected = _selectedMaterials.any((m) => m.cod == material.cod);
        final esRelacionado = referencia.contains(
          material.descripcion.toLowerCase(),
        );

        return CheckboxListTile(
          title: Text(material.descripcion),
          subtitle: Text('Precio: ${material.precio}'),
          secondary:
              esRelacionado
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.info_outline, color: Colors.grey),
          value: isSelected,
          onChanged: (bool? value) {
            if (value != null) {
              _onMaterialToggle(material, value);
            }
          },
        );
      },
    );
  }
}

class PersonalOwn extends StatefulWidget {
  final Function(List<Employee>) onSelectionChanged;
  final String? descripcionSolicitada; // <- NUEVO campo opcional
  const PersonalOwn({
    super.key,
    required this.onSelectionChanged,
    this.descripcionSolicitada,
  });

  @override
  State<PersonalOwn> createState() => _PersonalOwnState();
}

class _PersonalOwnState extends State<PersonalOwn> {
  final EmployeeService _employeeService = EmployeeService();
  List<Employee> _employeeList = [];
  List<Employee> _selectedEmployees = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      final allEmployees = await _employeeService.getAllEmployees();

      // Filtrar solo los disponibles
      final disponibles =
          allEmployees
              .where((e) => e.estado?.toLowerCase() == 'disponible')
              .toList();

      print("disponibles: ${disponibles.length}");

      setState(() {
        _employeeList = disponibles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) return Center(child: Text(_errorMessage));

    return ListView.builder(
      itemCount: _employeeList.length,
      itemBuilder: (context, index) {
        final employee = _employeeList[index];
        final isSelected = _selectedEmployees.any((e) => e.dni == employee.dni);

        return CheckboxListTile(
          title: Text(employee.nombre ?? ''),
          subtitle: Text('Categoría: ${employee.categoriaPersona ?? ''}'),
          value: isSelected,
          onChanged: (bool? value) {
            if (value != null) {
              _onEmployeeToggle(employee, value);
            }
          },
        );
      },
    );
  }

  void _onEmployeeToggle(Employee employee, bool selected) {
    setState(() {
      if (selected) {
        _selectedEmployees.add(employee);
      } else {
        _selectedEmployees.removeWhere((e) => e.dni == employee.dni);
      }
    });
    widget.onSelectionChanged(_selectedEmployees);
  }
}
