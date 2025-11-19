import 'package:flutter_application_2/models/material.dart';
import 'package:flutter_application_2/utils/response_result.dart';
import 'package:flutter_application_2/utils/urls.dart';

class MaterialService {
  // ========== OPERACIONES DE MATERIAL BASE ==========

  // Obtener todos los materiales
  Future<ResponseResult<List<Materials>>> getAllMaterials() async {
    try {
      final response = await Urls.getUrl('/materials', {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error obteniendo materiales',
          errorCode: 'FETCH_MATERIALS_FAILED',
        );
      }

      final List<Materials> materials =
          (response['data'] as List)
              .map((item) => Materials.fromJson(item))
              .toList();

      return ResponseResult.success(
        message: 'Materiales obtenidos exitosamente',
        data: materials,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Crear material base (solo en tabla Material)
  Future<ResponseResult<Materials>> createBaseMaterial(
    Materials material,
  ) async {
    try {
      final response = await Urls.postUrl('/materials', material.toJson(), {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error creando material',
          errorCode: 'CREATE_MATERIAL_FAILED',
        );
      }

      final createdMaterial = Materials.fromJson(response['data']);

      return ResponseResult.success(
        message: 'Material base creado exitosamente',
        data: createdMaterial,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Crear material completo (Material + MaterialEnInventario)
  Future<ResponseResult<Map<String, dynamic>>> createCompleteMaterial(
    Materials material,
    MaterialEnInventario inventoryData,
  ) async {
    try {
      // Primero crear el material base
      final materialResponse = await createBaseMaterial(material);

      if (!materialResponse.success) {
        return ResponseResult.error(
          message: materialResponse.message,
          errorCode: materialResponse.errorCode,
        );
      }

      // Luego crear el registro en inventario
      final inventoryResponse = await addToInventory(inventoryData);

      if (!inventoryResponse.success) {
        // Si falla el inventario, intentar eliminar el material base creado
        await deleteBaseMaterial(material.cod);
        return ResponseResult.error(
          message: 'Error creando inventario: ${inventoryResponse.message}',
          errorCode: 'CREATE_INVENTORY_FAILED',
        );
      }

      return ResponseResult.success(
        message: 'Material e inventario creados exitosamente',
        data: {
          'material': materialResponse.data!.toJson(),
          'inventory': inventoryResponse.data!.toJson(),
        },
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Actualizar material base
  Future<ResponseResult<Materials>> updateBaseMaterial(
    Materials material,
  ) async {
    try {
      final response = await Urls.putUrl(
        '/materials/${material.cod}',
        material.toJson(),
        {'Content-Type': 'application/json'},
      );

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error actualizando material',
          errorCode: 'UPDATE_MATERIAL_FAILED',
        );
      }

      final updatedMaterial = Materials.fromJson(response['data']);

      return ResponseResult.success(
        message: 'Material actualizado exitosamente',
        data: updatedMaterial,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Eliminar material base (solo de tabla Material)
  Future<ResponseResult<void>> deleteBaseMaterial(String cod) async {
    try {
      final response = await Urls.deleteUrl('/materials/$cod', {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error eliminando material',
          errorCode: 'DELETE_MATERIAL_FAILED',
        );
      }

      return ResponseResult.success(message: 'Material eliminado exitosamente');
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Eliminar material completo (Material + MaterialEnInventario)
  Future<ResponseResult<void>> deleteCompleteMaterial(String cod) async {
    try {
      // Primero eliminar de inventario
      final inventoryResult = await removeFromInventory(cod);

      // Luego eliminar material base (incluso si falló el inventario)
      final materialResult = await deleteBaseMaterial(cod);

      if (!materialResult.success) {
        return materialResult;
      }

      return ResponseResult.success(
        message:
            inventoryResult.success
                ? 'Material e inventario eliminados exitosamente'
                : 'Material eliminado (inventario ya no existía)',
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // ========== OPERACIONES DE INVENTARIO ==========

  // Obtener todo el inventario
  Future<ResponseResult<List<MaterialEnInventario>>>
  getMaterialInventory() async {
    try {
      final response = await Urls.getUrl('/materials/inventory', {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error obteniendo inventario',
          errorCode: 'FETCH_INVENTORY_FAILED',
        );
      }

      final List<MaterialEnInventario> inventory =
          (response['data'] as List)
              .map((item) => MaterialEnInventario.fromJson(item))
              .toList();

      return ResponseResult.success(
        message: 'Inventario obtenido exitosamente',
        data: inventory,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Agregar material al inventario
  Future<ResponseResult<MaterialEnInventario>> addToInventory(
    MaterialEnInventario inventoryData,
  ) async {
    try {
      final response = await Urls.postUrl(
        '/materials/inventory',
        inventoryData.toJson(),
        {'Content-Type': 'application/json'},
      );

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error agregando al inventario',
          errorCode: 'ADD_INVENTORY_FAILED',
        );
      }

      final addedInventory = MaterialEnInventario.fromJson(response['data']);

      return ResponseResult.success(
        message: 'Material agregado al inventario exitosamente',
        data: addedInventory,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Actualizar estado en inventario
  Future<ResponseResult<MaterialEnInventario>> updateInventoryStatus(
    String cod,
    EstadoMaterial nuevoEstado,
  ) async {
    try {
      final response = await Urls.putUrl(
        '/materials/inventory/$cod',
        {'estado': nuevoEstado.name},
        {'Content-Type': 'application/json'},
      );

      print("Response: $response");

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error actualizando estado',
          errorCode: 'UPDATE_INVENTORY_FAILED',
        );
      }

      final updatedInventory = MaterialEnInventario.fromJson(response['data']);

      return ResponseResult.success(
        message: 'Estado actualizado exitosamente',
        data: updatedInventory,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Actualizar inventario completo
  Future<ResponseResult<MaterialEnInventario>> updateInventory(
    MaterialEnInventario inventoryData,
  ) async {
    try {
      final response = await Urls.putUrl(
        '/materials/inventory/${inventoryData.cod}',
        inventoryData.toJson(),
        {'Content-Type': 'application/json'},
      );

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error actualizando inventario',
          errorCode: 'UPDATE_INVENTORY_FAILED',
        );
      }

      final updatedInventory = MaterialEnInventario.fromJson(response['data']);

      return ResponseResult.success(
        message: 'Inventario actualizado exitosamente',
        data: updatedInventory,
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Remover material del inventario
  Future<ResponseResult<void>> removeFromInventory(String cod) async {
    try {
      final response = await Urls.deleteUrl('/materials/inventory/$cod', {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error removiendo del inventario',
          errorCode: 'REMOVE_INVENTORY_FAILED',
        );
      }

      return ResponseResult.success(
        message: 'Material removido del inventario exitosamente',
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // ========== CONSULTAS COMBINADAS ==========

  // Obtener material con su información de inventario
  Future<ResponseResult<Map<String, dynamic>>> getMaterialWithInventory(
    String cod,
  ) async {
    try {
      final response = await Urls.getUrl('/materials/$cod/complete', {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message: response['message'] ?? 'Error obteniendo material completo',
          errorCode: 'FETCH_COMPLETE_MATERIAL_FAILED',
        );
      }

      return ResponseResult.success(
        message: 'Material completo obtenido exitosamente',
        data: response['data'],
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // ========== CONSULTAS ESPECÍFICAS ==========

  // Materiales disponibles en inventario
  Future<ResponseResult<List<Materials>>>
  getAvailableInventoryMaterials() async {
    try {
      final response = await Urls.getUrl('/materials/inventory/available', {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message:
              response['message'] ?? 'Error al cargar materiales de inventario',
        );
      }

      final materialsData = response['data'];
      return ResponseResult.success(
        message: 'Materiales de inventario cargados correctamente',
        data:
            materialsData
                .map<Materials>(
                  (materialJson) => Materials.fromJson(materialJson),
                )
                .toList(),
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // Materiales disponibles para alquiler
  Future<ResponseResult<List<Materials>>> getAvailableRentalMaterials() async {
    try {
      final response = await Urls.getUrl('/materials/rental/available', {
        'Content-Type': 'application/json',
      });

      if (response['status'] == false) {
        return ResponseResult.error(
          message:
              response['message'] ?? 'Error al cargar materiales de alquiler',
        );
      }

      final materialsData = response['data'];
      return ResponseResult.success(
        message: 'Materiales de alquiler cargados correctamente',
        data:
            materialsData
                .map<Materials>(
                  (materialJson) => Materials.fromJson(materialJson),
                )
                .toList(),
      );
    } catch (e) {
      return ResponseResult.error(
        message: 'Error de conexión: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  // ========== MÉTODOS DE CONVENIENCIA ==========

  // Método simplificado para crear material (decide automáticamente si agregar a inventario)
  Future<ResponseResult<Materials>> createMaterial(
    Materials material, {
    bool addToInventory = false,
    MaterialEnInventario? inventoryData,
  }) async {
    if (addToInventory && inventoryData != null) {
      final result = await createCompleteMaterial(material, inventoryData);
      if (result.success) {
        return ResponseResult.success(
          message: result.message,
          data: Materials.fromJson(result.data!['material']),
        );
      } else {
        return ResponseResult.error(
          message: result.message,
          errorCode: result.errorCode,
        );
      }
    } else {
      return await createBaseMaterial(material);
    }
  }

  // Método simplificado para eliminar material
  Future<ResponseResult<void>> deleteMaterial(
    String cod, {
    bool removeFromInventory = true,
  }) async {
    if (removeFromInventory) {
      return await deleteCompleteMaterial(cod);
    } else {
      return await deleteBaseMaterial(cod);
    }
  }

  // Método simplificado para actualizar material
  Future<ResponseResult<Materials>> updateMaterial(Materials material) async {
    return await updateBaseMaterial(material);
  }
}
