import 'package:mbosswater/features/guarantee/data/model/commune.dart';
import 'package:mbosswater/features/guarantee/data/model/district.dart';
import 'package:mbosswater/features/guarantee/data/model/province.dart';
import 'package:mbosswater/features/guarantee/domain/repository/address_repository.dart';

class AddressUseCase {
  final AddressRepository repository;

  AddressUseCase(this.repository);

  Future<List<Province>?> getProvinces() async {
    final response = await repository.fetchProvinces();
    return response.data;
  }
  Future<List<District>?> getDistricts(String pid) async {
    final response = await repository.fetchDistricts(pid);
    return response.data;
  }
  Future<List<Commune>?> getCommunes(String districtID) async {
    final response = await repository.fetchCommunes(districtID);
    return response.data;
  }
}