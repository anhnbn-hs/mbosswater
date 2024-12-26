import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/reminder.dart';

abstract class FetchCustomersState {}

class FetchCustomersInitial extends FetchCustomersState {}

class FetchCustomersLoading extends FetchCustomersState {}

class FetchCustomersLoaded extends FetchCustomersState {
  final List<CustomerReminder> customers;

  FetchCustomersLoaded(this.customers);
}

class FetchCustomersError extends FetchCustomersState {
  final String message;

  FetchCustomersError(this.message);
}

class FetchCustomersCubit extends Cubit<FetchCustomersState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FetchCustomersCubit() : super(FetchCustomersInitial());

  void reset() => emit(FetchCustomersInitial());

  Future<void> fetchCustomersByIds(List<Reminder> reminders) async {
    emit(FetchCustomersLoading());

    try {
      List<CustomerReminder> customerReminders =
          await _fetchCustomerReminders(reminders);
      emit(FetchCustomersLoaded(customerReminders));
    } catch (e) {
      emit(FetchCustomersError('Failed to load customers: $e'));
    }
  }

  Future<List<CustomerReminder>> _fetchCustomerReminders(
      List<Reminder> reminders) async {
    try {
      // Extract unique customer IDs from reminders
      final customerIds = reminders.map((r) => r.customerId).toSet().toList();

      // Fetch customers from Firestore
      final customersSnapshot = await _firestore
          .collection('customers')
          .where('id', whereIn: customerIds)
          .get();

      if (customersSnapshot.docs.isEmpty) {
        throw Exception('No customers found');
      }

      // Map Firestore documents to Customer objects
      final customers = customersSnapshot.docs
          .map((doc) => Customer.fromJson(doc.data()))
          .toList();

      // Create a mapping of customer ID to Customer
      final customerMap = {
        for (var customer in customers) customer.id!: customer
      };

      // Pair each Reminder with its corresponding Customer
      return reminders
          .where((reminder) => customerMap.containsKey(reminder.customerId))
          .map((reminder) => CustomerReminder(
                reminder: reminder,
                customer: customerMap[reminder.customerId]!,
              ))
          .toList();
    } catch (e) {
      throw Exception('Error fetching customer reminders: $e');
    }
  }

  void rebuildWhenLoaded() {
    if (state is FetchCustomersLoaded) {
      final loadedState = state as FetchCustomersLoaded;
      emit(FetchCustomersLoaded(List.from(loadedState.customers)));
    }
  }

}

class CustomerReminder {
  final Customer customer;
  final Reminder reminder;

  CustomerReminder({required this.reminder, required this.customer});
}
