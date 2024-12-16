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

      notificationsStream(userId).listen((notifications) {
        emit(NotificationLoaded(notifications));
      }, onError: (error) {
        emit(NotificationError('Failed to load notifications'));
      });
    } catch (e) {
      emit(NotificationError('Failed to subscribe to notifications'));
    }
  }

  Stream<List<NotificationModel>> notificationsStream(String userId) {
    try {
      return _firestore
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return NotificationModel.fromFirestore(doc);
        }).toList();
      });
    } catch (e) {
      return Stream.error('Failed to load notifications');
    }
  }

  // Add a new notification
  Future<void> addNotification(
      String userId, NotificationModel notification) async {
    try {
      final notificationData = notification.toFirestore();

      await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .add(notificationData);
    } catch (e) {
      emit(NotificationError('Failed to add notification'));
    }
  }

  // Update the 'isRead' field for a notification
  Future<void> updateNotificationStatus(
      String userId, String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      emit(NotificationError('Failed to update notification'));
    }
  }

  // Update the 'isRead' field for a notification
  Future<void> readAllNotification(String userId) async {
    try {
      final batch = _firestore.batch();

      final querySnapshot = await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .get();

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      emit(NotificationError('Failed to update notifications'));
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
    } catch (e) {
      emit(NotificationError('Failed to delete notification'));
    }
  }
}
