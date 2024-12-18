import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderDateModel {
  Timestamp reminderDate;
  String? note;
  bool isNotified;

  ReminderDateModel({
    required this.reminderDate,
    this.note,
    this.isNotified = false,
  });

  // Factory method to create a ReminderDateModel from Firestore data
  factory ReminderDateModel.fromJson(Map<String, dynamic> json) {
    return ReminderDateModel(
      reminderDate: json['reminderDate'] as Timestamp,
      note: json['note'] as String?,
      isNotified: json['isNotified'] ?? false,
    );
  }

  // Convert ReminderDateModel to a Firestore-compatible JSON map
  Map<String, dynamic> toJson() {
    return {
      'reminderDate': reminderDate,
      'note': note,
      'isNotified': isNotified,
    };
  }
}

class Reminder {
  final String? id;
  final String customerId;
  final String guaranteeId;
  final Timestamp createdAt;  // Firestore timestamp
  final DateTime endDate;  // DateTime for endDate
  List<ReminderDateModel>? reminderDates;  // List of reminder dates with notes and notifications

  Reminder({
    this.id,
    required this.customerId,
    required this.guaranteeId,
    required this.createdAt,
    required this.endDate,
    this.reminderDates,
  });

  // Factory method to create a Reminder from Firestore data
  factory Reminder.fromJson(Map<String, dynamic> json, String id) {
    return Reminder(
      id: id,
      customerId: json['customerId'] ?? '',
      guaranteeId: json['guaranteeId'] ?? '',
      createdAt: json['createdAt'] as Timestamp,  // Keep as Timestamp
      endDate: (json['endDate'] as Timestamp).toDate(),  // Convert Timestamp to DateTime
      reminderDates: (json['reminderDates'] as List<dynamic>?)
          ?.map((data) => ReminderDateModel.fromJson(data as Map<String, dynamic>))  // Convert to ReminderDateModel list
          .toList(),
    );
  }

  // Convert Reminder to a Firestore-compatible JSON map
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'guaranteeId': guaranteeId,
      'createdAt': createdAt,  // Store as Timestamp
      'endDate': Timestamp.fromDate(endDate),  // Convert DateTime to Timestamp
      'reminderDates': reminderDates?.map((date) => date.toJson()).toList(),  // Convert to JSON
    };
  }

  void generateReminderDates(int cycleMonths) {
    List<ReminderDateModel> dates = [];
    DateTime current = createdAt.toDate();  // Convert createdAt (Timestamp) to DateTime

    // Add reminder dates based on the cycleMonths interval
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      // Add cycleMonths to the current date
      current = DateTime(
        current.year,
        current.month + cycleMonths, // Add months
        current.day,
      );

      // Ensure the reminder doesn't go past the endDate
      if (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
        if (dates.length == 3) {
          break;
        }

        // Create ReminderDateModel for each reminder date
        dates.add(
          ReminderDateModel(
            reminderDate: Timestamp.fromDate(current),
            isNotified: false,
          ),
        );
      }
    }

    reminderDates = dates;
  }

  // Method to add a reminder date with a note and notification flag
  void addReminderDate(DateTime reminderDate, {String? note, bool isNotified = false}) {
    reminderDates ??= [];
    reminderDates!.add(ReminderDateModel(
      reminderDate: Timestamp.fromDate(reminderDate),
      note: note,
      isNotified: isNotified,
    ));
  }
}

