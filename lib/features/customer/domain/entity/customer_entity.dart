import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

class CustomerEntity {
  final Customer customer;
  final List<Guarantee> guarantees;

  CustomerEntity(this.customer, this.guarantees);

  factory CustomerEntity.fromJson(Map<String, dynamic> json) {
    return CustomerEntity(
      Customer.fromJson(json['customer']), // Deserialize Customer object
      (json['guarantees'] as List<dynamic>)
          .map((item) => Guarantee.fromJson(item as Map<String, dynamic>))
          .toList(), // Deserialize list of Guarantees
    );
  }
}
