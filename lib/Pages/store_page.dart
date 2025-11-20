import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/material.dart';
import 'package:flutter_application_2/service/material_service.dart';
import 'package:flutter_application_2/Pages/material_form_page.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with TickerProviderStateMixin {
  final MaterialService _materialService = MaterialService();
  List<Materials> _materials = [];
  List<MaterialEnInventario> _inventory = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMaterials();
    _loadInventory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _materialService.getAllMaterials();

    if (result.success && result.data != null) {
      setState(() {
        _materials = result.data!;
      });
    } else {
      _showSnackBar(result.message, Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadInventory() async {
    final result = await _materialService.getMaterialInventory();

    if (result.success && result.data != null) {
      setState(() {
        _inventory = result.data!;
      });
    } else {
      _showSnackBar(
        'Error cargando inventario: ${result.message}',
        Colors.orange,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  List<Materials> get _filteredMaterials {
    if (_searchQuery.isEmpty) return _materials;

    return _materials.where((material) {
      return material.cod.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (material.descripcion?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);
    }).toList();
  }

  List<MaterialEnInventario> get _filteredInventory {
    if (_searchQuery.isEmpty) return _inventory;

    return _inventory.where((item) {
      return item.cod.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _deleteMaterial(Materials material) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Eliminar Material'),
            content: Text(
              '¿Estás seguro de que quieres eliminar el material ${material.cod}?\nEsto también lo eliminará del inventario si existe.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final result = await _materialService.deleteMaterial(material.cod);

      if (result.success) {
        _showSnackBar('Material eliminado exitosamente', Colors.green);
        _loadMaterials();
        _loadInventory(); // Recargar inventario también
      } else {
        _showSnackBar(result.message, Colors.red);
      }
    }
  }

  Future<void> _addToInventory(Materials material) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Agregar al Inventario'),
            content: Text(
              '¿Quieres agregar ${material.cod} al inventario como disponible?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('Agregar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final inventoryItem = MaterialEnInventario(
        cod: material.cod,
        estado: EstadoMaterial.disponible,
        fechaFabricacion: DateTime.now(),
        diasDisponibilidad: DateTime(
          DateTime.now().year + 1,
          DateTime.now().month,
          DateTime.now().day,
        ),
      );

      final result = await _materialService.addToInventory(inventoryItem);

      if (result.success) {
        _showSnackBar('Material agregado al inventario', Colors.green);
        _loadInventory();
      } else {
        _showSnackBar(result.message, Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Almacén'),
        backgroundColor: Color(0xff142047),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [Tab(text: 'Materiales'), Tab(text: 'Inventario')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMaterialsTab(), _buildInventoryTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => MaterialFormPage()),
          );

          if (result == true) {
            _loadMaterials();
          }
        },
        backgroundColor: Color(0xff142047),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMaterialsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por código o descripción...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child:
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredMaterials.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay materiales registrados',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: _loadMaterials,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _filteredMaterials.length,
                      itemBuilder: (context, index) {
                        final material = _filteredMaterials[index];
                        final isInInventory = _inventory.any(
                          (item) => item.cod == material.cod,
                        );

                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xff142047),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isInInventory
                                    ? Icons.inventory
                                    : Icons.inventory_outlined,
                                color: Colors.white,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  material.cod,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (isInInventory) ...[
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'En Inventario',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (material.descripcion != null)
                                  Text(material.descripcion!),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (material.precio != null) ...[
                                      Icon(
                                        Icons.euro,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      Text('${material.precio}€'),
                                      SizedBox(width: 16),
                                    ],
                                    if (material.fechaIni != null) ...[
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      Text(
                                        '${material.fechaIni!.day}/${material.fechaIni!.month}/${material.fechaIni!.year}',
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => MaterialFormPage(
                                            material: material,
                                          ),
                                    ),
                                  );

                                  if (result == true) {
                                    _loadMaterials();
                                  }
                                } else if (value == 'delete') {
                                  _deleteMaterial(material);
                                } else if (value == 'add_inventory') {
                                  _addToInventory(material);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    if (!isInInventory)
                                      PopupMenuItem(
                                        value: 'add_inventory',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.add_box,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Agregar a Inventario'),
                                          ],
                                        ),
                                      ),
                                    PopupMenuItem(
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
                          ),
                        );
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildInventoryTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar en inventario...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _loadInventory,
                icon: Icon(Icons.refresh),
                label: Text('Actualizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff142047),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _inventory.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay materiales en inventario',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ve a la pestaña "Materiales" para agregar items al inventario',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredInventory.length,
                    itemBuilder: (context, index) {
                      final item = _filteredInventory[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: item.estadoColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.inventory_2, color: Colors.white),
                          ),
                          title: Text(
                            item.cod,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: item.estadoColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: item.estadoColor),
                                ),
                                child: Text(
                                  item.estadoTexto,
                                  style: TextStyle(
                                    color: item.estadoColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (item.fechaFabricacion != null) ...[
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.build,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Fabricación: ${item.fechaFabricacion!.day}/${item.fechaFabricacion!.month}/${item.fechaFabricacion!.year}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'change_status') {
                                _showChangeStatusDialog(item);
                              } else if (value == 'remove') {
                                _removeFromInventory(item);
                              }
                            },
                            itemBuilder:
                                (context) => [
                                  PopupMenuItem(
                                    value: 'change_status',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.swap_horiz,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Cambiar Estado'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'remove',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Quitar del Inventario'),
                                      ],
                                    ),
                                  ),
                                ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  void _showChangeStatusDialog(MaterialEnInventario item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cambiar Estado - ${item.cod}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  EstadoMaterial.values.map((estado) {
                    return ListTile(
                      title: Text(_getEstadoText(estado)),
                      leading: Icon(
                        Icons.circle,
                        color: _getColorForEstado(estado),
                      ),
                      selected: estado == item.estado,
                      onTap: () async {
                        Navigator.of(context).pop();
                        if (estado != item.estado) {
                          final result = await _materialService
                              .updateInventoryStatus(item.cod, estado);

                          print("resultttt: $result");

                          if (result.success) {
                            _showSnackBar(
                              'Estado actualizado exitosamente',
                              Colors.green,
                            );
                            _loadInventory();
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

  String _getEstadoText(EstadoMaterial estado) {
    switch (estado) {
      case EstadoMaterial.alquilado:
        return 'Alquilado';
      case EstadoMaterial.reservado:
        return 'Reservado';
      case EstadoMaterial.enUso:
        return 'En Uso';
      case EstadoMaterial.averiado:
        return 'Averiado';
      case EstadoMaterial.disponible:
        return 'Disponible';
    }
  }

  Color _getColorForEstado(EstadoMaterial estado) {
    switch (estado) {
      case EstadoMaterial.alquilado:
        return Colors.orange;
      case EstadoMaterial.reservado:
        return Colors.blue;
      case EstadoMaterial.enUso:
        return Colors.purple;
      case EstadoMaterial.averiado:
        return Colors.red;
      case EstadoMaterial.disponible:
        return Colors.green;
    }
  }

  Future<void> _removeFromInventory(MaterialEnInventario item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Quitar del Inventario'),
            content: Text(
              '¿Estás seguro de que quieres quitar ${item.cod} del inventario?\nEl material base seguirá existiendo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Quitar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final result = await _materialService.removeFromInventory(item.cod);

      if (result.success) {
        _showSnackBar('Material quitado del inventario', Colors.green);
        _loadInventory();
        _loadMaterials(); // Recargar materiales para actualizar indicadores
      } else {
        _showSnackBar(result.message, Colors.red);
      }
    }
  }
}
