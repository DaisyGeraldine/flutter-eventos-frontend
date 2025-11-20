import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/material.dart';
import 'package:flutter_application_2/service/material_service.dart';

class MaterialFormPage extends StatefulWidget {
  final Materials? material;

  const MaterialFormPage({Key? key, this.material}) : super(key: key);

  @override
  State<MaterialFormPage> createState() => _MaterialFormPageState();
}

class _MaterialFormPageState extends State<MaterialFormPage> {
  final _formKey = GlobalKey<FormState>();
  final MaterialService _materialService = MaterialService();

  late TextEditingController _codController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  
  DateTime? _fechaIni;
  DateTime? _fechaFin;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codController = TextEditingController(text: widget.material?.cod ?? '');
    _descripcionController = TextEditingController(text: widget.material?.descripcion ?? '');
    _precioController = TextEditingController(text: widget.material?.precio?.toString() ?? '');
    _fechaIni = widget.material?.fechaIni;
    _fechaFin = widget.material?.fechaFin;
  }

  @override
  void dispose() {
    _codController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.material != null;

  Future<void> _selectDate(BuildContext context, bool isFechaIni) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isFechaIni ? _fechaIni : _fechaFin) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFechaIni) {
          _fechaIni = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar fecha';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final material = Materials(
      cod: _codController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty 
          ? null 
          : _descripcionController.text.trim(),
      fechaIni: _fechaIni,
      fechaFin: _fechaFin,
      precio: _precioController.text.trim().isEmpty 
          ? null 
          : double.tryParse(_precioController.text.trim()),
      estado: null,
      empresaProveedora: null,
    );

    final result = isEditing 
        ? await _materialService.updateMaterial(material)
        : await _materialService.createMaterial(material);

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
        title: Text(isEditing ? 'Editar Material' : 'Nuevo Material'),
        backgroundColor: Color(0xff142047),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _codController,
                        enabled: !isEditing, // No permitir cambiar código al editar
                        decoration: InputDecoration(
                          labelText: 'Código *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.tag),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El código es obligatorio';
                          }
                          if (value.trim().length > 9) {
                            return 'El código no puede tener más de 9 caracteres';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descripcionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value != null && value.length > 200) {
                            return 'La descripción no puede tener más de 200 caracteres';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _precioController,
                        decoration: InputDecoration(
                          labelText: 'Precio (€)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.euro),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final precio = double.tryParse(value.trim());
                            if (precio == null) {
                              return 'Ingresa un precio válido';
                            }
                            // if (precio > 32767) {
                            //   return 'El precio no puede ser mayor a 32767';
                            // }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fechas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Fecha Inicio',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(_formatDate(_fechaIni)),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Fecha Fin',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(_formatDate(_fechaFin)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMaterial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff142047),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'Actualizar Material' : 'Crear Material',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}