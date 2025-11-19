import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

// Colores principales de la aplicación
const Color kDarkBackground = Color(0xFF1C1C1E);
const Color kGoldColor = Color(0xFFD4AF37);
const Color kMaroonColor = Color(0xFF8B1E3F);

/// Pantalla inicial que verifica la autenticación y configura notificaciones push
/// Esta pantalla se muestra brevemente mientras se realizan dos procesos en paralelo:
/// 1. Verificar si el usuario debe autenticarse con huella dactilar
/// 2. Configurar Firebase Cloud Messaging para notificaciones push
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    // Ejecuta ambas tareas simultáneamente para optimizar tiempo de carga
    _checkAuth(); // Verifica configuración de autenticación biométrica
    setupFlutterNotifications(); // Configura el sistema de notificaciones push
  }

  /// Verifica si el usuario tiene habilitada la autenticación biométrica
  /// y lo redirige a la pantalla correspondiente según el resultado
  ///
  /// Flujo:
  /// 1. Lee preferencias para ver si la huella está activada
  /// 2. Si está activada, solicita autenticación biométrica
  /// 3. Si autenticación exitosa -> HomeScreen
  /// 4. Si falla o no está activada -> LoginScreen
  Future<void> _checkAuth() async {
    // Obtiene las preferencias compartidas donde se guarda la configuración
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final LocalAuthService authService = LocalAuthService();

    // Lee la preferencia 'usarHuella', por defecto es false
    final bool usarHuella = prefs.getBool('usarHuella') ?? false;

    // Delay breve para mostrar la pantalla de splash
    await Future.delayed(const Duration(milliseconds: 500));

    if (usarHuella) {
      // Solicita autenticación biométrica (huella, Face ID, etc.)
      final bool didAuthenticate = await authService.authenticate(
        'Por favor, autentícate para abrir MovieMood',
      );

      if (didAuthenticate && mounted) {
        // Autenticación exitosa - redirige a la pantalla principal
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (mounted) {
        // Autenticación fallida - redirige al login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      // La huella no está habilitada - va directo al login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  /// Configura Firebase Cloud Messaging para recibir notificaciones push
  /// Este método se ejecuta en paralelo con _checkAuth() para no bloquear el inicio
  ///
  /// Configura tres listeners para diferentes estados de la app:
  /// 1. onMessage - App en primer plano (muestra SnackBar)
  /// 2. onMessageOpenedApp - App en background y usuario toca la notificación
  /// 3. getInitialMessage - App cerrada y se abre por una notificación
  Future<void> setupFlutterNotifications() async {
    final fcm = FirebaseMessaging.instance;

    // Solicita permisos de notificación al usuario
    // En iOS aparece un diálogo nativo, en Android se conceden automáticamente
    NotificationSettings settings = await fcm.requestPermission(
      alert: true, // Permite mostrar alertas visuales
      badge: true, // Permite badge en el ícono de la app
      sound: true, // Permite reproducir sonidos
      provisional: false, // No usa notificaciones provisionales en iOS
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Usuario concedió permiso (Firebase)');

      // Obtiene el token único del dispositivo para enviar notificaciones push
      // Este token debe enviarse al backend para que pueda dirigir notificaciones
      final fcmToken = await fcm.getToken();
      print('=======================================');
      print('FCM Token: $fcmToken');
      print('=======================================');

      // Listener 1: Notificaciones cuando la app está en primer plano
      // Muestra un SnackBar con el título y cuerpo de la notificación
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('¡Llegó un mensaje en primer plano! (Firebase)');
        if (message.notification != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: kGoldColor,
                content: Text(
                  '${message.notification!.title} \n ${message.notification!.body}',
                  style: TextStyle(color: kDarkBackground),
                ),
              ),
            );
          }
        }
      });

      // Listener 2: Usuario toca una notificación mientras la app está en background
      // Útil para navegar a una pantalla específica según el contenido
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Usuario tocó notificación desde background (Firebase):');
        print(
          'Message data: ${message.data}',
        ); // data contiene payload personalizado
      });

      // Listener 3: App fue abierta desde estado terminado por una notificación
      // Se ejecuta solo una vez al inicio si la app se abrió por una notificación
      RemoteMessage? initialMessage = await fcm.getInitialMessage();
      if (initialMessage != null) {
        print(
          'App abierta desde estado terminado por notificación (Firebase):',
        );
        print('Message data: ${initialMessage.data}');
      }
    } else {
      // El usuario rechazó los permisos de notificación
      print('Usuario denegó el permiso (Firebase)');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Muestra un indicador de carga mientras se ejecutan los procesos de inicialización
    return const Scaffold(
      backgroundColor: kDarkBackground,
      body: Center(child: CircularProgressIndicator(color: kGoldColor)),
    );
  }
}
