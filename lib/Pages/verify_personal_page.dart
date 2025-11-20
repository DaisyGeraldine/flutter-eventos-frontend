import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/event.dart';
import 'package:flutter_application_2/models/material.dart';
import 'package:flutter_application_2/models/personal.dart';
import 'package:flutter_application_2/service/event_service.dart';
import 'package:flutter_application_2/service/material_service.dart';
import 'package:flutter_application_2/service/personal_service.dart';
import 'package:flutter_application_2/utils/response_result.dart';
import 'package:intl/intl.dart';

class VerifyAvailabilityPage extends StatefulWidget {
  final Event? event;
  const VerifyAvailabilityPage({super.key, required this.event});

  @override
  State<VerifyAvailabilityPage> createState() => _VerifyAvailabilityPageState();
}

class _VerifyAvailabilityPageState extends State<VerifyAvailabilityPage> {
  List<Personal> internalStaff = [];
  List<Personal> externalStaff = [];

  List<Materials> inventoryMaterial = [];
  List<Materials> rentalMaterial = [];

  Set<String> selectedInternalStaff = {};
  Set<String> selectedExternalStaff = {};
  Set<String> selectedInventoryMaterial = {};
  Set<String> selectedRentalMaterial = {};

  final TextEditingController _presupuestoController = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final MaterialService _materialService = MaterialService();
    final PersonalService _personalService = PersonalService();

    final ResponseResult<List<Personal>> internalStaffResult =
        await _personalService.getAvailableInternalStaff();
    final ResponseResult<List<Personal>> externalStaffResult =
        await _personalService.getAvailableExternalStaff();
    final ResponseResult<List<Materials>> inventoryMaterialResult =
        await _materialService.getAvailableInventoryMaterials();
    final ResponseResult<List<Materials>> rentalMaterialResult =
        await _materialService.getAvailableRentalMaterials();

    try {
      internalStaff = internalStaffResult.data ?? [];
      externalStaff = externalStaffResult.data ?? [];
      inventoryMaterial = inventoryMaterialResult.data ?? [];
      rentalMaterial = rentalMaterialResult.data ?? [];
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _confirm() async {
    if (_presupuestoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor, ingresa el presupuesto"),
          backgroundColor: Colors.orange[700],
        ),
      );
      return;
    }

    final EventService _eventService = EventService();

    final fechaInicio = widget.event!.fechaIni;
    final fechaFin = widget.event!.fechaFin;
    final horaPrevistaInicio = DateTime.now();
    final double presupuesto =
        double.tryParse(_presupuestoController.text) ?? 0.0;

    // 🔹 Armar los datos correctos según tus modelos
    final selectedInternalStaffData =
        internalStaff
            .where((s) => selectedInternalStaff.contains(s.dni))
            .map(
              (s) => {
                "dni": s.dni,
                "fechaIni": fechaInicio.toIso8601String(),
                "fechaFin": fechaFin.toIso8601String(),
              },
            )
            .toList();

    final selectedExternalStaffData =
        externalStaff
            .where((s) => selectedExternalStaff.contains(s.dni))
            .map(
              (s) => {
                "dni": s.dni,
                "precio": s.precio,
                "fechaIni": fechaInicio.toIso8601String(),
                "fechaFin": fechaFin.toIso8601String(),
              },
            )
            .toList();

    final selectedInventoryMaterialData =
        inventoryMaterial
            .where((m) => selectedInventoryMaterial.contains(m.cod))
            .map(
              (m) => {
                "codMaterial": m.cod,
                "precio": m.precio,
                "fechaIni": fechaInicio.toIso8601String(),
                "fechaFin": fechaFin.toIso8601String(),
              },
            )
            .toList();

    final selectedRentalMaterialData =
        rentalMaterial
            .where((m) => selectedRentalMaterial.contains(m.cod))
            .map(
              (m) => {
                "codMaterial": m.cod,
                "precio": m.precio,
                "fechaIni": fechaInicio.toIso8601String(),
                "fechaFin": fechaFin.toIso8601String(),
              },
            )
            .toList();

    // 🔹 Enviar datos al backend
    final ResponseResult result = await _eventService.prepareEvent(
      eventCode: widget.event!.cod,
      fechaIni: fechaInicio,
      fechaFin: fechaFin,
      horaPrevistaInicio: horaPrevistaInicio,
      presupuesto: presupuesto,
      selectedInternalStaff: selectedInternalStaffData,
      selectedExternalStaff: selectedExternalStaffData,
      selectedInventoryMaterial: selectedInventoryMaterialData,
      selectedRentalMaterial: selectedRentalMaterialData,
    );

    if (result.success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Evento preparado exitosamente"),
          backgroundColor: Colors.greenAccent,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${result.message}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Cargando recursos disponibles..."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verificar Disponibilidad"),
        backgroundColor: const Color(0xff142047),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Detalle del evento (fijo en la parte superior)
          _buildEventDetail(),
          // Lista scrolleable con las secciones expandibles
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPresupuestoSection(),
                const SizedBox(height: 16),
                _buildExpandableSection(
                  title: "Personal Interno",
                  subtitle:
                      "${selectedInternalStaff.length} seleccionados de ${internalStaff.length}",
                  icon: Icons.people,
                  color: Colors.blue,
                  children: internalStaff.map(_buildInternalStaffTile).toList(),
                ),
                const SizedBox(height: 12),
                _buildExpandableSection(
                  title: "Personal Externo",
                  subtitle:
                      "${selectedExternalStaff.length} seleccionados de ${externalStaff.length}",
                  icon: Icons.people_outline,
                  color: Colors.orange,
                  children: externalStaff.map(_buildExternalStaffTile).toList(),
                ),
                const SizedBox(height: 12),
                _buildExpandableSection(
                  title: "Material de Inventario",
                  subtitle:
                      "${selectedInventoryMaterial.length} seleccionados de ${inventoryMaterial.length}",
                  icon: Icons.inventory,
                  color: Colors.green,
                  children:
                      inventoryMaterial.map(_buildInventoryMatTile).toList(),
                ),
                const SizedBox(height: 12),
                _buildExpandableSection(
                  title: "Material de Alquiler",
                  subtitle:
                      "${selectedRentalMaterial.length} seleccionados de ${rentalMaterial.length}",
                  icon: Icons.shopping_cart,
                  color: Colors.purple,
                  children: rentalMaterial.map(_buildRentalMatTile).toList(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _hasSelections() ? _confirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff142047),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Confirmar Preparación",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetail() {
    final evento = widget.event!;
    return Container(
      width: double.infinity,
      color: const Color(0xff142047),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            evento.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                "${DateFormat('dd/MM/yyyy').format(evento.fechaIni)} - ${DateFormat('dd/MM/yyyy').format(evento.fechaFin)}",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  evento.direccion,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                "${evento.duracion} horas",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person_rounded,
              color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                "Personal requerido: ${evento.descripcionPersonal}",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.category,
              color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                "Material requerido: ${evento.descripcionMaterial}",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresupuestoSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.euro, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  "Presupuesto del Evento",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _presupuestoController,
              decoration: InputDecoration(
                labelText: 'Presupuesto (€) *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.euro),
                hintText: 'Ej: 5000.00',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El presupuesto es obligatorio';
                }
                final presupuesto = double.tryParse(value.trim());
                if (presupuesto == null) {
                  return 'Ingresa un presupuesto válido';
                }
                if (presupuesto <= 0) {
                  return 'El presupuesto debe ser mayor a 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        children: [
          if (children.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "No hay elementos disponibles",
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }

  Widget _buildInternalStaffTile(Personal s) {
    return CheckboxListTile(
      title: Text("${s.nombre} ${s.apellidos}"),
      subtitle: Text(s.category ?? 'Sin categoría'),
      value: selectedInternalStaff.contains(s.dni),
      onChanged:
          (v) => setState(() {
            v!
                ? selectedInternalStaff.add(s.dni)
                : selectedInternalStaff.remove(s.dni);
          }),
      secondary: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Text(
          s.nombre.isNotEmpty ? s.nombre[0].toUpperCase() : '?',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildExternalStaffTile(Personal s) {
    return CheckboxListTile(
      title: Text("${s.nombre} ${s.apellidos}"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.category ?? 'Sin categoría'),
          if (s.precio != null)
            Text(
              "Precio: €${s.precio}",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      value: selectedExternalStaff.contains(s.dni),
      onChanged:
          (v) => setState(() {
            v!
                ? selectedExternalStaff.add(s.dni)
                : selectedExternalStaff.remove(s.dni);
          }),
      secondary: CircleAvatar(
        backgroundColor: Colors.orange.withOpacity(0.1),
        child: Text(
          s.nombre.isNotEmpty ? s.nombre[0].toUpperCase() : '?',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInventoryMatTile(Materials m) {
    return CheckboxListTile(
      title: Text(m.descripcion ?? 'Sin descripción'),
      subtitle: Text("Código: ${m.cod}"),
      value: selectedInventoryMaterial.contains(m.cod),
      onChanged:
          (v) => setState(() {
            v!
                ? selectedInventoryMaterial.add(m.cod)
                : selectedInventoryMaterial.remove(m.cod);
          }),
      secondary: CircleAvatar(
        backgroundColor: Colors.green.withOpacity(0.1),
        child: Icon(Icons.inventory, color: Colors.green),
      ),
    );
  }

  Widget _buildRentalMatTile(Materials m) {
    return CheckboxListTile(
      title: Text(m.descripcion ?? 'Sin descripción'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Código: ${m.cod}"),
          if (m.empresaProveedora != null)
            Text(
              "Proveedor: ${m.empresaProveedora}",
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (m.precio != null)
            Text(
              "Precio: €${m.precio}",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      value: selectedRentalMaterial.contains(m.cod),
      onChanged:
          (v) => setState(() {
            v!
                ? selectedRentalMaterial.add(m.cod)
                : selectedRentalMaterial.remove(m.cod);
          }),
      secondary: CircleAvatar(
        backgroundColor: Colors.purple.withOpacity(0.1),
        child: Icon(Icons.shopping_cart, color: Colors.purple),
      ),
    );
  }

  bool _hasSelections() {
    return selectedInternalStaff.isNotEmpty ||
        selectedExternalStaff.isNotEmpty ||
        selectedInventoryMaterial.isNotEmpty ||
        selectedRentalMaterial.isNotEmpty;
  }

  // Widget _title(String txt) => Padding(
  //   padding: const EdgeInsets.only(bottom: 8),
  //   child: Text(
  //     txt,
  //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //   ),
  // );

  // Widget _internalStaffTile(Personal s) => CheckboxListTile(
  //   title: Text("${s.nombre} ${s.apellidos} (${s.category})"),
  //   value: selectedInternalStaff.contains(s.dni),
  //   onChanged:
  //       (v) => setState(() {
  //         v!
  //             ? selectedInternalStaff.add(s.dni)
  //             : selectedInternalStaff.remove(s.dni);
  //       }),
  // );

  // Widget _externalStaffTile(Personal s) => CheckboxListTile(
  //   title: Text("${s.nombre} ${s.apellidos} (${s.category})"),
  //   value: selectedExternalStaff.contains(s.dni),
  //   onChanged:
  //       (v) => setState(() {
  //         v!
  //             ? selectedExternalStaff.add(s.dni)
  //             : selectedExternalStaff.remove(s.dni);
  //       }),
  // );

  // Widget _inventoryMatTile(Materials m) => CheckboxListTile(
  //   title: Text("${m.descripcion}"),
  //   value: selectedInventoryMaterial.contains(m.cod),
  //   onChanged:
  //       (v) => setState(() {
  //         v!
  //             ? selectedInventoryMaterial.add(m.cod)
  //             : selectedInventoryMaterial.remove(m.cod);
  //       }),
  // );

  // Widget _rentalMatTile(Materials m) => CheckboxListTile(
  //   title: Text("${m.descripcion} (provider: ${m.empresaProveedora})"),
  //   value: selectedRentalMaterial.contains(m.cod),
  //   onChanged:
  //       (v) => setState(() {
  //         v!
  //             ? selectedRentalMaterial.add(m.cod)
  //             : selectedRentalMaterial.remove(m.cod);
  //       }),
  // );
}
