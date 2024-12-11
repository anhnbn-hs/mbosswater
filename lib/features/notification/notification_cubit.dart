import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/notification/notification_state.dart';
import 'notification_model.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationCubit() : super(NotificationInitial());

  // Fetch notifications for a user
  Future<void> fetchNotifications(String userId) async {
    try {
      emit(NotificationLoading());

      final querySnapshot = await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .get();

      final notifications = querySnapshot.docs.map((doc) {
        return NotificationModel.fromFirestore(doc);
      }).toList();

      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError('Failed to load notifications'));
    }
  }

  // Update the 'isRead' field for a notification
  Future<void> updateNotificationStatus(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .doc(notificationId)
          .update({'isRead': true});

      emit(NotificationUpdated());
    } catch (e) {
      emit(NotificationError('Failed to update notification'));
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .doc(notificationId)
          .delete();

      emit(NotificationDeleted());
    } catch (e) {
      emit(NotificationError('Failed to delete notification'));
    }
  }
}
