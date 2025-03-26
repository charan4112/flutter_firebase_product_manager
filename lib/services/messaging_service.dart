import 'package:firebase_messaging/firebase_messaging.dart';

// This function handles background messages.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If using other Firebase services in the background, initialize Firebase.
  print('Handling a background message: ${message.messageId}');
}

class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permissions for iOS (no-op on Android)
    await _messaging.requestPermission();

    // Set the background messaging handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Listen for foreground messages.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.messageId}');
      if (message.notification != null) {
        print('Notification title: ${message.notification!.title}');
        print('Notification body: ${message.notification!.body}');
      }
    });

    // Optionally, you can also handle messages when the app is opened from a terminated state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('User tapped on notification: ${message.messageId}');
    });
  }
}

