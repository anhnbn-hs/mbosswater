import 'package:mbosswater/features/customer/data/datasource/customer_datasource.dart';
import 'package:mbosswater/features/customer/domain/entity/customer_entity.dart';
import 'package:mbosswater/features/customer/domain/repository/customer_repository.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
 class CustomerRepositoryImpl extends CustomerRepository {
  final CustomerDatasource datasource;

  CustomerRepositoryImpl(this.datasource);

  @override
  Future<Customer > fetchCustomer(String phoneNumber) async {
    return await datasource.fetchCustomer(phoneNumber);
  }

  @override
  Future<List<Customer>> fetchCustomers()  async {
    return await datasource.fetchCustomers();
  }

  @override
  Future<List<Customer>> searchCustomers(String phoneNumberQuery) async {
    return await datasource.searchCustomers(phoneNumberQuery);
  }

  @override
  Future<List<Guarantee>> fetchGuaranteesOfCustomer(String customerID) async {
    return await datasource.fetchGuaranteesOfCustomer(customerID);
  }

  @override
  Future<List<CustomerEntity>> fetchCustomersOfAgency(String agencyID) async {
    return await datasource.fetchCustomersOfAgency(agencyID);
  }

  @override
  Future<List<Customer>> searchCustomersOfAgency(String phoneNumberQuery, String agencyID) async {
   return await datasource.searchCustomersOfAgency(phoneNumberQuery, agencyID);
  }

  @override
  Future<List<CustomerEntity>> fetchCustomersEntity()async {
    return await datasource.fetchCustomersEntity();
  }

  @override
  Future<Customer> fetchCustomerByProductID(String productID) async {
    return await datasource.fetchCustomerByProductID(productID);
  }


}
