import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Khởi tạo plugin và timezone với cài đặt mặc định cho Android.
  /// Sử dụng múi giờ 'Asia/Ho_Chi_Minh' làm mặc định.
  static Future<void> initialize() async {
    // Khởi tạo timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // Yêu cầu quyền thông báo trên Android 13 trở lên
    await _requestNotificationPermission();

    // Cài đặt Android với biểu tượng mặc định của hệ thống
    const androidSettings = AndroidInitializationSettings('@android:drawable/ic_dialog_info');

    // Tổng hợp cài đặt
    const initSettings = InitializationSettings(android: androidSettings);

    // Khởi tạo plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Yêu cầu quyền thông báo trên Android 13 trở lên
  static Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  /// Xử lý khi người dùng nhấn vào thông báo.
  static void _onNotificationTap(NotificationResponse response) {
    // Thêm logic xử lý khi nhấn thông báo (ví dụ: điều hướng đến màn hình cụ thể)
    // Có thể mở rộng dựa trên payload nếu cần.
  }

  /// Gửi thông báo ngay lập tức với ID, tiêu đề và nội dung.
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      channelDescription: 'Kênh thông báo chính',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, notificationDetails, payload: payload);
  }

  /// Gửi thông báo theo thời gian hẹn với ID, tiêu đề, nội dung và thời gian.
  static Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_channel',
          'Scheduled Notifications',
          channelDescription: 'Kênh thông báo theo lịch',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// Gửi thông báo định kỳ với tiêu đề, nội dung và khoảng thời gian lặp lại.
  static Future<void> showPeriodicNotifications({
    required String title,
    required String body,
    required RepeatInterval interval,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'periodic_channel',
      'Periodic Notifications',
      channelDescription: 'Kênh thông báo định kỳ',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _notifications.periodicallyShow(
      0, // ID mặc định cho thông báo định kỳ
      title,
      body,
      interval,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Hủy thông báo theo ID.
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Hủy tất cả thông báo.
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}