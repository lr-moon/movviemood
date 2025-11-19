// --- IMPORTS DE FIREBASE ---
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // El archivo generado de Firebase

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth_check_screen.dart';
import 'models/auth_provider.dart';
import 'services/resena_repositoy.dart';

// --- MANEJADOR DE MENSAJES EN BACKGROUND (PARA FIREBASE) ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Handling a background message: ${message.messageId}");
}

// --- COLORES para el tema ---
const Color kDarkBackground = Color(0xFF1C1C1E);
const Color kGoldColor = Color(0xFFD4AF37);
const Color kMaroonColor = Color(0xFF8B1E3F);

// --- main() PARA FIREBASE) ---
void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ResenaService()),
      ],
      child: const MyApp(),
    ),
  );
}

// --- CLASE MyApp  ---
class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieMood', 
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kDarkBackground,
        primaryColor: kMaroonColor,
        colorScheme: const ColorScheme.dark(
          primary: kMaroonColor,
          secondary: kGoldColor,
          background: kDarkBackground,
          onSecondary: Colors.black, 
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kGoldColor,
            foregroundColor: kDarkBackground,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kMaroonColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const AuthCheckScreen(),
    );
  }
}