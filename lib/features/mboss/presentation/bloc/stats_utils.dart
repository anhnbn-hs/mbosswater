import 'package:cloud_firestore/cloud_firestore.dart';

class StatsUtils {
  // Singleton instance
  static final StatsUtils instance = StatsUtils._();
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // Private constructor for singleton
  StatsUtils._();

  // Method to get customer count for a specific staff
  Future<int> getCustomerOfStaffCount(String staffID) async {
    try {
      // Use Firestore count aggregation
      final countQuerySnapshot = await firebaseFirestore
          .collection("guarantees")
          .where("technicalID", isEqualTo: staffID)
          .count()
          .get();
      return countQuerySnapshot.count ?? 0;
    } catch (e) {
      print("Error fetching customer count: $e");
      return 0;
    }
  }

  Future<int> getCustomerOfStaffCountWithFilter({
    required String staffID,
    required String filterValue,
  }) async {
    try {
      // Tạo tham số thời gian lọc
      DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
      DateTime startDate;

      switch (filterValue) {
        case "Tháng này":
          // Lấy ngày đầu tiên của tháng hiện tại
          startDate = DateTime(now.year, now.month, 1);
          break;

        case "30 ngày gần đây":
          startDate = now.subtract(const Duration(days: 30));
          break;

        case "90 ngày gần đây":
          startDate = now.subtract(const Duration(days: 90));
          break;

        case "Năm nay":
          startDate = DateTime(now.year, 1, 1);
          break;

        default:
          print("Invalid filter value: $filterValue");
          return 0;
      }

      Timestamp startTimestamp = Timestamp.fromDate(startDate);

      final countQuerySnapshot = await firebaseFirestore
          .collection("guarantees")
          .where("technicalID", isEqualTo: staffID)
          .where("createdAt", isGreaterThanOrEqualTo: startTimestamp)
          .count()
          .get();

      return countQuerySnapshot.count ?? 0;
    } catch (e) {
      print("Error fetching customer count: $e");
      return 0;
    }
  }
}
