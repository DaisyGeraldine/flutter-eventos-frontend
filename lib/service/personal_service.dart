import 'package:flutter_application_2/models/personal.dart';
import 'package:flutter_application_2/utils/response_result.dart';
import 'package:flutter_application_2/utils/urls.dart';

class PersonalService {
  // GET /staff/available
  Future<ResponseResult<List<Personal>>> getAvailableInternalStaff() async {
    final response = await Urls.getUrl('/staff/available', {
      'Content-Type': 'application/json',
    });

    if (response['status'] == false) {
      return ResponseResult.error(
        message: response['message'] ?? 'Error al cargar personal interno',
      );
    }

    final staffData = response['data'];
    return ResponseResult<List<Personal>>.success(
      message: 'Personal interno cargado correctamente',
      data:
          staffData
              .map<Personal>((personalJson) => Personal.fromJson(personalJson))
              .toList(),
    );
  }

  // GET /staff/external
  Future<ResponseResult<List<Personal>>> getAvailableExternalStaff() async {
    final response = await Urls.getUrl('/staff/external', {
      'Content-Type': 'application/json',
    });

    if (response['status'] == false) {
      return ResponseResult.error(
        message: response['message'] ?? 'Error al cargar personal externo',
      );
    }

    final staffData = response['data'];
    return ResponseResult<List<Personal>>.success(
      message: 'Personal externo cargado correctamente',
      data:
          staffData
              .map<Personal>((personalJson) => Personal.fromJson(personalJson))
              .toList(),
    );
  }
}
