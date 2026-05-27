import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotification {
  final String id;
  final String title;
  final String message;
  final DateTime receivedAt;
  bool isRead;
  DateTime? readAt;

  LocalNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.receivedAt,
    this.isRead = false,
    this.readAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'receivedAt': receivedAt.toIso8601String(),
        'isRead': isRead,
        'readAt': readAt?.toIso8601String(),
      };

  factory LocalNotification.fromJson(Map<String, dynamic> json) =>
      LocalNotification(
        id: json['id'],
        title: json['title'],
        message: json['message'],
        receivedAt: DateTime.parse(json['receivedAt']),
        isRead: json['isRead'] ?? false,
        readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      );
}

class NotificationsController extends GetxController {
  static NotificationsController get instance => Get.find();

  final _storage = GetStorage();
  final _storageKey = 'local_push_notifications';

  RxList<LocalNotification> notifications = <LocalNotification>[].obs;
  RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() {
    final List<dynamic>? storedDocs = _storage.read<List<dynamic>>(_storageKey);
    if (storedDocs != null) {
      final loaded = storedDocs
          .map((e) => LocalNotification.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final now = DateTime.now();
      notifications.value = loaded.where((n) {
        if (n.isRead && n.readAt != null) {
          return now.difference(n.readAt!).inMinutes < 60;
        } else {
          return now.difference(n.receivedAt).inHours < 24;
        }
      }).toList();

      if (notifications.length != loaded.length) {
        _persist();
      }

      // Sort by newest first
      notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
      _updateUnreadCount();
    }
  }

  Future<void> saveIncomingMessage(RemoteMessage message) async {
    // Avoid saving if both title and body are empty
    if (message.notification?.title == null &&
        message.notification?.body == null) {
      return;
    }

    // Check if we already saved this message ID to prevent duplicates
    if (message.messageId != null) {
      bool exists = notifications.any((n) => n.id == message.messageId);
      if (exists) return;
    }

    final newNotif = LocalNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'New Announcement',
      message: message.notification?.body ?? '',
      receivedAt: message.sentTime ?? DateTime.now(),
      isRead: false,
    );

    notifications.insert(0, newNotif); // Insert at top

    // Keep only last 50 notifications to avoid bloating storage
    if (notifications.length > 50) {
      notifications.removeLast();
    }

    _updateUnreadCount();
    await _persist();
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAllAsRead() async {
    bool changed = false;
    final now = DateTime.now();
    for (var notif in notifications) {
      if (!notif.isRead) {
        notif.isRead = true;
        notif.readAt = now;
        changed = true;
      }
    }
    if (changed) {
      unreadCount.value = 0;
      notifications.refresh(); // Update UI
      await _persist();
    }
  }

  void cleanUpExpired() {
    final now = DateTime.now();
    final initialCount = notifications.length;
    notifications.removeWhere((n) {
      if (n.isRead && n.readAt != null) {
        return now.difference(n.readAt!).inMinutes >= 60;
      } else {
        return now.difference(n.receivedAt).inHours >= 24;
      }
    });
    
    if (notifications.length != initialCount) {
      _updateUnreadCount();
      _persist();
    }
  }

  Future<void> _persist() async {
    final jsonList = notifications.map((e) => e.toJson()).toList();
    await _storage.write(_storageKey, jsonList);
  }
}
