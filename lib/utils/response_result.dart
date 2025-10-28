class ResponseResult<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;
  final int? statusCode;

  ResponseResult({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
    this.statusCode,
  });

  // Factory constructors para casos comunes
  factory ResponseResult.success({
    required String message,
    T? data,
    int? statusCode,
  }) {
    return ResponseResult<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ResponseResult.error({
    required String message,
    String? errorCode,
    int? statusCode,
  }) {
    return ResponseResult<T>(
      success: false,
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    );
  }

  // Método para verificar si hay datos
  bool get hasData => data != null;

  // Método para obtener datos como mapa
  Map<String, dynamic>? get asMap {
    if (data is Map<String, dynamic>) {
      return data as Map<String, dynamic>;
    }
    return null;
  }

  // Método para obtener datos como lista
  List<T>? get asList {
    if (data is List<T>) {
      return data as List<T>;
    }
    return null;
  }

  @override
  String toString() {
    return 'ResponseResult(success: $success, message: $message, hasData: $hasData)';
  }
}
