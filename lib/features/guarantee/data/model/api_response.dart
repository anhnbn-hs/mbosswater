class ApiResponse<T> {
  int? total;
  List<T>? data;
  String? code;
  String? message;

  ApiResponse({this.total, this.data, this.code, this.message});

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT
      ) {
    return ApiResponse<T>(
      total: json['total'],
      data: json['data'] != null
          ? List<T>.from(json['data'].map((item) => fromJsonT(item)))
          : null,
      code: json['code'],
      message: json['message'],
    );
  }
}


