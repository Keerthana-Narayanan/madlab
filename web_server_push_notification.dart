// pubsec yaml file
// name: push_notifications_demo
// description: A Flutter app demonstrating push notification subscription and management.
// version: 1.0.0+1

// environment:
//   sdk: ">=3.0.0 <4.0.0"

// dependencies:
//   flutter:
//     sdk: flutter
//   firebase_core: ^2.25.4
//   firebase_messaging: ^14.7.4
//   http: ^0.13.6

// dev_dependencies:
//   flutter_test:
//     sdk: flutter

// flutter:
//   uses-material-design: true
// -------------------------------------
// (android/app/google-services.json) add file in this location
// --------------------------------
// ( android/build.gradle) add below code in this location 
// buildscript {
//   dependencies {
//     classpath 'com.google.gms:google-services:4.4.0'
//   }
// }
// -----------------------------------------
// (android/app/build.gradle )add below code in this location 
// apply plugin: 'com.google.gms.google-services'
// defaultConfig {
//     minSdkVersion 19
// }


// 4. Android Permissions (android/app/src/main/AndroidManifest.xml)
// Inside <manifest>:


// <uses-permission android:name="android.permission.INTERNET"/>
// <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
// ---------------------------------------------------------
// Inside <application>:

// <service
//     android:name="com.google.firebase.messaging.FirebaseMessagingService"
//     android:exported="true">
//     <intent-filter>
//         <action android:name="com.google.firebase.MESSAGING_EVENT"/>
//     </intent-filter>
// </service>

// <receiver
//     android:name="com.google.firebase.iid.FirebaseInstanceIdReceiver"
//     android:exported="true"
//     android:permission="com.google.android.c2dm.permission.SEND">
//     <intent-filter>
//         <action android:name="com.google.android.c2dm.intent.RECEIVE"/>
//         <category android:name="${applicationId}"/>
//     </intent-filter>
// </receiver>
// ------------------------------------------------------------------------
// 5. Firebase Initialization File (Optional but good practice)
// Create a new file:
// 📄 lib/firebase_options.dart
// Use the Firebase CLI to auto-generate this with:

// flutterfire configure
// Then in your main.dart (if using firebase_options.dart), initialize Firebase like this:


// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );
// ------------------------------------------------
// 🔄 Steps to Convert .kts to Groovy DSL
// Rename the File: Change the filename from build.gradle.kts to build.gradle.​

// Adjust the plugins Block:

// Kotlin DSL:

// plugins {
//     kotlin("jvm") version "1.5.21"
// }
// --------------------------------
// Groovy DSL:

// plugins {
//     id 'org.jetbrains.kotlin.jvm' version '1.5.21'
// }
// -------------------------------------------
// Modify the repositories Block:

// Kotlin DSL:

// repositories {
//     mavenCentral()
// }
// -------------------
// Groovy DSL:

// repositories {
//     mavenCentral()
// }
// -----------------------------
// Update the dependencies Block:

// Kotlin DSL:

// dependencies {
//     implementation(kotlin("stdlib"))
//     testImplementation(kotlin("test"))
// }
// Groovy DSL:

// dependencies {
//     implementation 'org.jetbrains.kotlin:kotlin-stdlib'
//     testImplementation 'org.jetbrains.kotlin:kotlin-test'
// }
// ---------------------------------------------
// Revise Task Definitions:

// Kotlin DSL:

// tasks.test {
//     useJUnitPlatform()
// }
// Groovy DSL:

// test {
//     useJUnitPlatform()
// }
// ----------------------------------------------
// Handle String Interpolation:

// Kotlin DSL: Uses ${project.rootDir}.​
// Android Developers

// Groovy DSL: Can use $project.rootDir directly.​

// Variable Declarations:

// Kotlin DSL: Uses val or var.​
// Android Developers

// Groovy DSL: Uses def.​

// 🛠️ Tools to Assist in Conversion
// For automated assistance, consider using online tools like Gradle Kotlinize, which can help convert Groovy DSL to Kotlin DSL. While it primarily focuses on the opposite conversion, understanding the differences can aid in manual conversion.​
// gradle-kotlinize.web.app

// 📄 Additional Files to Consider
// Beyond the build.gradle.kts file, ensure you also convert other related files:​

// settings.gradle.kts: Rename to settings.gradle and adjust syntax accordingly.​

// gradle.properties: Typically remains unchanged, but review for any Kotlin-specific configurations.​

// Custom Scripts: Any custom .gradle.kts scripts should be renamed and their syntax adjusted to Groovy DSL.​




import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FirebaseMessaging _messaging;
  String? _token;
  String subscriptionStatus = "Not subscribed";
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _messaging = FirebaseMessaging.instance;
    _messaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        notifications.insert(
          0,
          "${message.notification?.title ?? 'No Title'} - ${message.notification?.body ?? 'No Body'}",
        );
      });
    });
  }

  Future<void> _subscribe() async {
    try {
      _token = await _messaging.getToken();
      print("FCM Token: $_token");

      final response = await http.post(
        Uri.parse("http://192.168.0.103:5000/subscribe"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': 'user1', 'token': _token}),
      );

      setState(() {
        subscriptionStatus = response.statusCode == 200
            ? "Subscribed successfully"
            : "Subscription failed";
      });
    } catch (e) {
      setState(() {
        subscriptionStatus = "Error: $e";
      });
    }
  }

  Future<void> _unsubscribe() async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/unsubscribe"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': 'user1'}),
      );

      setState(() {
        subscriptionStatus = response.statusCode == 200
            ? "Unsubscribed successfully"
            : "Unsubscribe failed";
      });
    } catch (e) {
      setState(() {
        subscriptionStatus = "Error: $e";
      });
    }
  }

  Future<void> _refreshToken() async {
    _token = await _messaging.getToken(); // force refresh
    setState(() {});
  }

  void _testNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Pretend a test notification was received.")),
    );

    setState(() {
      notifications.insert(0, "🔔 Test Notification - Hello from Flutter!");
    });
  }

  Widget _buildButton(String label, IconData icon, VoidCallback onPressed,
      {Color? color}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Push Notifications Demo",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Push Notifications"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 2,
                child: ListTile(
                  title: const Text("Subscription Status"),
                  subtitle: Text(subscriptionStatus),
                  leading: const Icon(Icons.notifications_active),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildButton("Subscribe", Icons.subscriptions, _subscribe),
                  _buildButton("Unsubscribe", Icons.cancel, _unsubscribe,
                      color: Colors.redAccent),
                  _buildButton("Refresh Token", Icons.refresh, _refreshToken),
                  _buildButton(
                      "Test Notification", Icons.send, _testNotification,
                      color: Colors.orange),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                child: ExpansionTile(
                  title: const Text("FCM Token (Click to Expand)"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(_token ?? "Token not generated"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: notifications.isEmpty
                    ? const Center(
                        child: Text("No notifications received yet."))
                    : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 1,
                            child: ListTile(
                              leading: const Icon(Icons.message),
                              title: Text(notifications[index]),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
