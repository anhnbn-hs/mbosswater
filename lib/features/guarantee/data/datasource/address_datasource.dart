import 'package:dio/dio.dart';
import 'package:mbosswater/features/guarantee/data/model/api_response.dart';
import 'package:mbosswater/features/guarantee/data/model/commune.dart';
import 'package:mbosswater/features/guarantee/data/model/district.dart';
import 'package:mbosswater/features/guarantee/data/model/province.dart';

class AddressDatasource {
  final dio = Dio();
  final _baseUrl = 'https://open.oapi.vn/location';

  Future<ApiResponse<Province>> fetchProvinces() async {
    try {
      Response response = await dio.get('$_baseUrl/provinces?page=0&size=63');
      return ApiResponse<Province>.fromJson(
        response.data,
        (item) => Province.fromJson(item),
      );
    } on Exception catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<ApiResponse<District>> fetchDistricts(String provinceID) async {
    try {
      Response response =
          await dio.get('$_baseUrl/districts/$provinceID?size=50');
      return ApiResponse<District>.fromJson(
        response.data,
        (item) => District.fromJson(item),
      );
    } on Exception catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<ApiResponse<Commune>> fetchCommunes(String districtID) async {
    try {
      Response response =
      await dio.get('$_baseUrl/wards/$districtID?size=50');
      return ApiResponse<Commune>.fromJson(
        response.data,
            (item) => Commune.fromJson(item),
      );
    } on Exception catch (e) {
      print(e);
      rethrow;
    }
  }
}
