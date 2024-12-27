import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'customer_stats_event.dart';

part 'customer_stats_state.dart';

class CustomerStatsBloc extends Bloc<CustomerStatsEvent, CustomerStatsState> {
  CustomerStatsBloc() : super(CustomerStatsInitial()) {
    on<CustomerStatsEvent>((event, emit) async {
      try {
        Query query = FirebaseFirestore.instance.collection('customers');

        if (event.provinceFilter != null && event.provinceFilter != 'Tất cả') {
          query =
              query.where('address.province', isEqualTo: event.provinceFilter);
        }

        if (event.timeFilter != null && event.timeFilter != 'Tất cả') {
          DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
          DateTime startDate;

          switch (event.timeFilter) {
            case 'Tháng này':
              startDate = DateTime(now.year, now.month, 1);
              break;
            case '30 ngày gần đây':
              startDate = now.subtract(const Duration(days: 30));
              break;
            case '90 ngày gần đây':
              startDate = now.subtract(const Duration(days: 90));
              break;
            case 'Năm nay':
              startDate = DateTime(now.year, 1, 1);
              break;
            default:
              startDate = now;
          }

          query = query.where('updatedAt', isGreaterThanOrEqualTo: startDate);
        }


        if (event.agency != null) {
          query = query.where('agency', isEqualTo: event.agency);
        }

        // Fetch customer count
        final customerCountSnapshot = await query.count().get();
        final totalCustomers = customerCountSnapshot.count ?? 0;

        final productsSnapshot = await query.get();

        int totalProductSold = 0;
        for (var doc in productsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalProductSold += (data['totalProduct'] ?? 0) as int;
        }

        emit(CustomerStatsSuccess(
          totalCustomer: totalCustomers,
          totalProductSold: totalProductSold,
        ));
      } catch (e) {
        emit(CustomerStatsError());
      }
    });
  }
}
