import 'package:flutter_application_2/models/material.dart';
import 'package:flutter_application_2/utils/response_result.dart';
import 'package:flutter_application_2/utils/urls.dart';

class MaterialService {
  // GET /material/inventory/available
  Future<ResponseResult<List<Materials>>>
  getAvailableInventoryMaterials() async {
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
    return ResponseResult<List<Materials>>.success(
      message: 'Materiales de inventario cargados correctamente',
      data:
          materialsData
              .map<Materials>(
                (materialJson) => Materials.fromJson(materialJson),
              )
              .toList(),
    );
  }

  // GET /material/rental/available
  Future<ResponseResult<List<Materials>>> getAvailableRentalMaterials() async {
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
    return ResponseResult<List<Materials>>.success(
      message: 'Materiales de alquiler cargados correctamente',
      data:
          materialsData
              .map<Materials>(
                (materialJson) => Materials.fromJson(materialJson),
              )
              .toList(),
    );
  }
}
