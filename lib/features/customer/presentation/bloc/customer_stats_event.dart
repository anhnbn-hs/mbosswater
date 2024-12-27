part of 'customer_stats_bloc.dart';

final class CustomerStatsEvent{
  String? timeFilter;
  String? provinceFilter;
  String? agency;

  CustomerStatsEvent({
    this.timeFilter,
    this.provinceFilter,
    this.agency,
  });
}
