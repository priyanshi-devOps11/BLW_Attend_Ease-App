import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _notifications.initialize(initSettings);
  }

  static Future<void> showCheckoutReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'attendance_channel',
      'Attendance Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'Don’t forget to Check-Out!',
      'You are still checked-in. Please check-out before leaving.',
      details,
    );
  }
}
