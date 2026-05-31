class ApiResponse<T> {
  final T? data;
  final String? error;
  final int statusCode;

  const ApiResponse({this.data, this.error, required this.statusCode});

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  factory ApiResponse.success(T data, int statusCode) =>
      ApiResponse(data: data, statusCode: statusCode);

  factory ApiResponse.failure(String error, int statusCode) =>
      ApiResponse(error: error, statusCode: statusCode);
}

// 공통 에러 코드 (API 명세서 기준)
class ApiError {
  static const unauthorized = 'UNAUTHORIZED';
  static const forbidden = 'FORBIDDEN';
  static const notFound = 'NOT_FOUND';
  static const aiError = 'AI_SERVICE_ERROR';
  static const ocrError = 'OCR_PROCESSING_ERROR';
  static const medicalValidation = 'MEDICAL_DATA_VALIDATION_FAILED';
}
