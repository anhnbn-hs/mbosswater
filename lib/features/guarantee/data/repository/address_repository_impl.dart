import 'package:mbosswater/features/guarantee/data/datasource/address_datasource.dart';
import 'package:mbosswater/features/guarantee/data/model/api_response.dart';
import 'package:mbosswater/features/guarantee/data/model/commune.dart';
import 'package:mbosswater/features/guarantee/data/model/district.dart';
import 'package:mbosswater/features/guarantee/data/model/province.dart';
import 'package:mbosswater/features/guarantee/domain/repository/address_repository.dart';

class AddressRepositoryImpl extends AddressRepository{
  final AddressDatasource datasource;

  AddressRepositoryImpl(this.datasource);

  @override
  Future<ApiResponse<Commune>> fetchCommunes(String districtID) async {
    return await datasource.fetchCommunes(districtID);
  }

  @override
  Future<ApiResponse<District>> fetchDistricts(String provinceID) async {
    return await datasource.fetchDistricts(provinceID);
  }

  @override
  Future<ApiResponse<Province>> fetchProvinces()  async {
    return await datasource.fetchProvinces();
  }
}