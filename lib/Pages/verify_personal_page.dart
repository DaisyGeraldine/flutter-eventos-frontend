import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/event.dart';
import 'package:flutter_application_2/models/material.dart';
import 'package:flutter_application_2/models/personal.dart';
import 'package:flutter_application_2/service/event_service.dart';
import 'package:flutter_application_2/service/material_service.dart';
import 'package:flutter_application_2/service/personal_service.dart';
import 'package:flutter_application_2/utils/response_result.dart';

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
    final EventService _eventService = EventService();

    final fechaInicio = widget.event!.fechaIni;
    final fechaFin = widget.event!.fechaFin;
    final horaPrevistaInicio = DateTime.now();
    final double presupuesto =
        double.tryParse(_presupuestoController.text) ?? 0.0;

    // 🔹 Armar los datos correctos según tus modelos
    final selectedInternalStaffData = internalStaff
        .where((s) => selectedInternalStaff.contains(s.dni))
        .map((s) => {
              "dni": s.dni,
              "fechaIni": fechaInicio.toIso8601String(),
              "fechaFin": fechaFin.toIso8601String(),
            })
        .toList();

    final selectedExternalStaffData = externalStaff
        .where((s) => selectedExternalStaff.contains(s.dni))
        .map((s) => {
              "dni": s.dni,
              "precio": s.precio,
              "fechaIni": fechaInicio.toIso8601String(),
              "fechaFin": fechaFin.toIso8601String(),
            })
        .toList();

    final selectedInventoryMaterialData = inventoryMaterial
        .where((m) => selectedInventoryMaterial.contains(m.cod))
        .map((m) => {
              "codMaterial": m.cod,
              "precio": m.precio,
              "fechaIni": fechaInicio.toIso8601String(),
              "fechaFin": fechaFin.toIso8601String(),
            })
        .toList();

    final selectedRentalMaterialData = rentalMaterial
        .where((m) => selectedRentalMaterial.contains(m.cod))
        .map((m) => {
              "codMaterial": m.cod,
              "precio": m.precio,
              "fechaIni": fechaInicio.toIso8601String(),
              "fechaFin": fechaFin.toIso8601String(),
            })
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
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${result.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Verificación: ${widget.event?.nombre}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _title("Personal Interno"),
          ...internalStaff.map(_internalStaffTile),
          Divider(),

          _title("Personal Externo"),
          ...externalStaff.map(_externalStaffTile),
          Divider(),

          _title("Material de Inventario"),
          ...inventoryMaterial.map(_inventoryMatTile),
          Divider(),

          _title("Material de Alquiler"),
          ...rentalMaterial.map(_rentalMatTile),

          const SizedBox(height: 24),
          ElevatedButton(onPressed: _confirm, child: const Text("Confirmar")),
        ],
      ),
    );
  }

  Widget _title(String txt) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      txt,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _internalStaffTile(Personal s) => CheckboxListTile(
    title: Text("${s.nombre} ${s.apellidos} (${s.category})"),
    value: selectedInternalStaff.contains(s.dni),
    onChanged:
        (v) => setState(() {
          v!
              ? selectedInternalStaff.add(s.dni)
              : selectedInternalStaff.remove(s.dni);
        }),
  );

  Widget _externalStaffTile(Personal s) => CheckboxListTile(
    title: Text("${s.nombre} ${s.apellidos} (${s.category})"),
    value: selectedExternalStaff.contains(s.dni),
    onChanged:
        (v) => setState(() {
          v!
              ? selectedExternalStaff.add(s.dni)
              : selectedExternalStaff.remove(s.dni);
        }),
  );

  Widget _inventoryMatTile(Materials m) => CheckboxListTile(
    title: Text("${m.descripcion}"),
    value: selectedInventoryMaterial.contains(m.cod),
    onChanged:
        (v) => setState(() {
          v!
              ? selectedInventoryMaterial.add(m.cod)
              : selectedInventoryMaterial.remove(m.cod);
        }),
  );

  Widget _rentalMatTile(Materials m) => CheckboxListTile(
    title: Text("${m.descripcion} (provider: ${m.empresaProveedora})"),
    value: selectedRentalMaterial.contains(m.cod),
    onChanged:
        (v) => setState(() {
          v!
              ? selectedRentalMaterial.add(m.cod)
              : selectedRentalMaterial.remove(m.cod);
        }),
  );
}
