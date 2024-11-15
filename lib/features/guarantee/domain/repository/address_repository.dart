import 'package:mbosswater/features/guarantee/data/model/api_response.dart';
import 'package:mbosswater/features/guarantee/data/model/commune.dart';
import 'package:mbosswater/features/guarantee/data/model/district.dart';
import 'package:mbosswater/features/guarantee/data/model/province.dart';

abstract class AddressRepository {
  Future<ApiResponse<Province>> fetchProvinces();
  Future<ApiResponse<District>> fetchDistricts(String provinceID);
  Future<ApiResponse<Commune>> fetchCommunes(String districtID);
}