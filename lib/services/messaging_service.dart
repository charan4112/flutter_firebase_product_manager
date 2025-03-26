import 'package:firebase_messaging/firebase_messaging.dart';

// Handles background messages.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    // Request permissions (iOS only; no effect on Android).
    await _messaging.requestPermission();
    
    // Set the background messaging handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Listen for messages when the app is in the foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.messageId}');
      if (message.notification != null) {
        print('Notification title: ${message.notification!.title}');
        print('Notification body: ${message.notification!.body}');
      }
    });
    
    // Handle messages when the app is opened from a terminated state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('User tapped on notification: ${message.messageId}');
    });
  }
}
