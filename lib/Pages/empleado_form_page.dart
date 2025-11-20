import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/employee.dart';
import 'package:flutter_application_2/service/personal_service.dart';

class EmpleadoFormPage extends StatefulWidget {
  final EmployeeComplete? empleado;

  const EmpleadoFormPage({Key? key, this.empleado}) : super(key: key);

  @override
  State<EmpleadoFormPage> createState() => _EmpleadoFormPageState();
}

class _EmpleadoFormPageState extends State<EmpleadoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final PersonalService _personalService = PersonalService();

  // Controladores para información personal (Persona)
  late TextEditingController _dniController;
  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _direccionController;

  // Controladores para información de empleado
  late TextEditingController _numSSController;
  late TextEditingController _contratosHorasController;
  late TextEditingController _emailController;
  late TextEditingController _contrasenaController;
  late TextEditingController _telefonoController;

  CategoriaPersona? _selectedCategoria;
  EstadoEmpleado? _selectedEstado;
  DateTime? _fechaAlta;
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _dniController = TextEditingController(text: widget.empleado?.dni ?? '');
    _nombreController = TextEditingController(text: widget.empleado?.nombre ?? '');
    _apellidosController = TextEditingController(text: widget.empleado?.apellidos ?? '');
    _direccionController = TextEditingController(text: widget.empleado?.direccion ?? '');
    _numSSController = TextEditingController(text: widget.empleado?.numSS ?? '');
    _contratosHorasController = TextEditingController(text: widget.empleado?.contratosHoras?.toString() ?? '');
    _emailController = TextEditingController(text: widget.empleado?.email ?? '');
    _contrasenaController = TextEditingController(text: widget.empleado?.contrasena ?? '');
    _telefonoController = TextEditingController(text: widget.empleado?.telefono ?? '');

    _selectedCategoria = widget.empleado?.categoriaPersona;
    _selectedEstado = widget.empleado?.estado ?? EstadoEmpleado.disponible;
    _fechaAlta = widget.empleado?.fechaAlta ?? DateTime.now();
  }

  @override
  void dispose() {
    _dniController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _direccionController.dispose();
    _numSSController.dispose();
    _contratosHorasController.dispose();
    _emailController.dispose();
    _contrasenaController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.empleado != null;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaAlta ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _fechaAlta) {
      setState(() {
        _fechaAlta = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar fecha';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveEmpleado() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una categoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final empleado = EmployeeComplete(
      dni: _dniController.text.trim(),
      nombre: _nombreController.text.trim().isEmpty ? null : _nombreController.text.trim(),
      apellidos: _apellidosController.text.trim().isEmpty ? null : _apellidosController.text.trim(),
      direccion: _direccionController.text.trim().isEmpty ? null : _direccionController.text.trim(),
      numSS: _numSSController.text.trim().isEmpty ? null : _numSSController.text.trim(),
      categoriaPersona: _selectedCategoria,
      contratosHoras: _contratosHorasController.text.trim().isEmpty 
          ? null 
          : int.tryParse(_contratosHorasController.text.trim()),
      fechaAlta: _fechaAlta,
      estado: _selectedEstado,
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      contrasena: _contrasenaController.text.trim().isEmpty ? null : _contrasenaController.text.trim(),
      telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
    );

    final result = isEditing
        ? await _personalService.updateEmpleado(empleado)
        : await _personalService.createEmpleado(empleado);

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Empleado' : 'Nuevo Empleado'),
        backgroundColor: const Color(0xff142047),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Información Personal
                  _buildSectionCard(
                    'Información Personal',
                    Icons.person,
                    [
                      _buildDNIField(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildNombreField()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildApellidosField()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDireccionField(),
                      const SizedBox(height: 16),
                      _buildTelefonoField(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Información Laboral
                  _buildSectionCard(
                    'Información Laboral',
                    Icons.work,
                    [
                      _buildNumSSField(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildCategoriaField()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildEstadoField()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildContratosHorasField()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildFechaAltaField()),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Información de Acceso
                  _buildSectionCard(
                    'Información de Acceso',
                    Icons.security,
                    [
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildContrasenaField(),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveEmpleado,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff142047),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(isEditing ? 'Actualizar' : 'Crear'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xff142047)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDNIField() {
    return TextFormField(
      controller: _dniController,
      decoration: InputDecoration(
        labelText: 'DNI *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.badge),
        hintText: '12345678A',
      ),
      enabled: !isEditing, // El DNI no se puede cambiar al editar
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El DNI es obligatorio';
        }
        if (value.trim().length != 9) {
          return 'El DNI debe tener 9 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildNombreField() {
    return TextFormField(
      controller: _nombreController,
      decoration: InputDecoration(
        labelText: 'Nombre',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.person),
      ),
      validator: (value) {
        if (value != null && value.trim().length > 20) {
          return 'El nombre no puede tener más de 20 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildApellidosField() {
    return TextFormField(
      controller: _apellidosController,
      decoration: InputDecoration(
        labelText: 'Apellidos',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.person_outline),
      ),
      validator: (value) {
        if (value != null && value.trim().length > 30) {
          return 'Los apellidos no pueden tener más de 30 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildDireccionField() {
    return TextFormField(
      controller: _direccionController,
      decoration: InputDecoration(
        labelText: 'Dirección',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.home),
      ),
      validator: (value) {
        if (value != null && value.trim().length > 50) {
          return 'La dirección no puede tener más de 50 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildTelefonoField() {
    return TextFormField(
      controller: _telefonoController,
      decoration: InputDecoration(
        labelText: 'Teléfono',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.phone),
        hintText: '+34 123 456 789',
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value != null && value.trim().length > 15) {
          return 'El teléfono no puede tener más de 15 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildNumSSField() {
    return TextFormField(
      controller: _numSSController,
      decoration: InputDecoration(
        labelText: 'Número de Seguridad Social',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.security),
        hintText: '123456789012',
      ),
      validator: (value) {
        if (value != null && value.trim().length > 12) {
          return 'El número de SS no puede tener más de 12 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildCategoriaField() {
    return DropdownButtonFormField<CategoriaPersona>(
      value: _selectedCategoria,
      decoration: InputDecoration(
        labelText: 'Categoría *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.category),
      ),
      items: CategoriaPersona.values.map((categoria) {
        return DropdownMenuItem(
          value: categoria,
          child: Text(_getCategoriaTexto(categoria)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoria = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'La categoría es obligatoria';
        }
        return null;
      },
    );
  }

  Widget _buildEstadoField() {
    return DropdownButtonFormField<EstadoEmpleado>(
      value: _selectedEstado,
      decoration: InputDecoration(
        labelText: 'Estado',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.circle),
      ),
      items: EstadoEmpleado.values.map((estado) {
        return DropdownMenuItem(
          value: estado,
          child: Text(_getEstadoTexto(estado)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedEstado = value;
        });
      },
    );
  }

  Widget _buildContratosHorasField() {
    return TextFormField(
      controller: _contratosHorasController,
      decoration: InputDecoration(
        labelText: 'Horas Contratadas',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.schedule),
        suffixText: 'h/semana',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          final horas = int.tryParse(value.trim());
          if (horas == null) {
            return 'Ingresa un número válido';
          }
          if (horas < 0 || horas > 168) {
            return 'Las horas deben estar entre 0 y 168';
          }
        }
        return null;
      },
    );
  }

  Widget _buildFechaAltaField() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha de Alta',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    _formatDate(_fechaAlta),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.email),
        hintText: 'usuario@empresa.com',
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          if (value.trim().length > 50) {
            return 'El email no puede tener más de 50 caracteres';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
            return 'Ingresa un email válido';
          }
        }
        return null;
      },
    );
  }

  Widget _buildContrasenaField() {
    return TextFormField(
      controller: _contrasenaController,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
      ),
      obscureText: !_showPassword,
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          if (value.trim().length > 60) {
            return 'La contraseña no puede tener más de 60 caracteres';
          }
          if (value.trim().length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres';
          }
        }
        return null;
      },
    );
  }

  String _getCategoriaTexto(CategoriaPersona categoria) {
    switch (categoria) {
      case CategoriaPersona.gerente:
        return 'Gerente';
      case CategoriaPersona.organizacion:
        return 'Organización';
      case CategoriaPersona.encargadoAlmacen:
        return 'Encargado de Almacén';
      case CategoriaPersona.tecnicoLuces:
        return 'Técnico de Luces';
      case CategoriaPersona.tecnicoSonido:
        return 'Técnico de Sonido';
      case CategoriaPersona.mozo:
        return 'Mozo';
    }
  }

  String _getEstadoTexto(EstadoEmpleado estado) {
    switch (estado) {
      case EstadoEmpleado.disponible:
        return 'Disponible';
      case EstadoEmpleado.deBaja:
        return 'De Baja';
      case EstadoEmpleado.enEvento:
        return 'En Evento';
      case EstadoEmpleado.vacaciones:
        return 'Vacaciones';
      case EstadoEmpleado.reservado:
        return 'Reservado';
    }
  }
}