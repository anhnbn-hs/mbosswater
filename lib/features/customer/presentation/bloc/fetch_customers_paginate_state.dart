import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';

abstract class FetchCustomersPaginateState {}

class FetchCustomersInitial extends FetchCustomersPaginateState {}

class FetchCustomersLoading extends FetchCustomersPaginateState {}

class FetchCustomersLoaded extends FetchCustomersPaginateState {
  final List<Customer> customers;
  final bool hasMore;
  final bool isLoadingMore;
  final DocumentSnapshot? lastDocument; // Cursor for Firestore pagination

  FetchCustomersLoaded({
    required this.customers,
    required this.hasMore,
    this.isLoadingMore = false,
    this.lastDocument,
  });

  FetchCustomersLoaded copyWith({
    List<Customer>? customers,
    bool? hasMore,
    bool? isLoadingMore,
    dynamic lastDocument,
  }) {
    return FetchCustomersLoaded(
      customers: customers ?? this.customers,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}

class FetchCustomersError extends FetchCustomersPaginateState {
  final String message;

  FetchCustomersError({required this.message});
}

class FetchCustomersPaginating extends FetchCustomersPaginateState {}

class FetchCustomersEndOfList extends FetchCustomersPaginateState {}
