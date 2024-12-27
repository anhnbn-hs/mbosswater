part of 'customer_stats_bloc.dart';

@immutable
sealed class CustomerStatsState {}

final class CustomerStatsInitial extends CustomerStatsState {}

final class CustomerStatsLoading extends CustomerStatsState {}

final class CustomerStatsSuccess extends CustomerStatsState {
  final int totalProductSold;
  final int totalCustomer;

  CustomerStatsSuccess(
      {required this.totalProductSold, required this.totalCustomer});
}

final class CustomerStatsError extends CustomerStatsState {}
