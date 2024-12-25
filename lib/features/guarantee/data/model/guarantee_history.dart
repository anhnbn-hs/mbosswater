import 'package:cloud_firestore/cloud_firestore.dart';

class GuaranteeHistory {
  final String guaranteeID;
  final String? technicalID;
  final String? technicalName;
  final String? beforeStatus;
  final String? afterStatus;
  final String? imageBefore;
  final String? imageAfter;
  final Timestamp? date;

  GuaranteeHistory({
    required this.guaranteeID,
    this.technicalID,
    this.technicalName,
    this.beforeStatus,
    this.afterStatus,
    this.date,
    this.imageAfter,
    this.imageBefore,
  });

  // Factory constructor to create an instance from a JSON map
  factory GuaranteeHistory.fromJson(Map<String, dynamic> json) {
    return GuaranteeHistory(
        guaranteeID: json['guaranteeID'] as String,
        technicalID: json['technicalID'] as String?,
        technicalName: json['technicalName'] as String?,
        // Parse new field
        beforeStatus: json['beforeStatus'] as String?,
        afterStatus: json['afterStatus'] as String?,
        date: json['date'] != null ? (json['date'] as Timestamp) : null,
        imageAfter: json['imageAfter'],
        imageBefore: json['imageBefore']);
  }

  // Method to convert the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'technicalID': technicalID,
      'technicalName': technicalName,
      'beforeStatus': beforeStatus,
      'afterStatus': afterStatus,
      'date': date,
      'guaranteeID': guaranteeID,
      'imageBefore': imageBefore,
      'imageAfter': imageAfter,
    };
  }
}
