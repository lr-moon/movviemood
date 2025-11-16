// Importa los widgets de Material Design para la interfaz.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- MODIFICADO ---
// Importa la nueva pantalla de verificación que decide si mostrar login o huella.
import 'screens/auth_check_screen.dart';
// --- NUEVO ---
// Importa el AuthProvider.
import 'models/auth_provider.dart';
// --- NUEVO ---
import 'services/resena_repositoy.dart';

// --- TUS COLORES (para el tema) ---
const Color kDarkBackground = Color(0xFF1C1C1E);
const Color kGoldColor = Color(0xFFD4AF37);
const Color kMaroonColor = Color(0xFF8B1E3F);

// Función principal que inicia la aplicación.
void main() => runApp(
      // Envuelve la app con MultiProvider para gestionar los estados.
      MultiProvider( 
        providers: [
          // Registra el AuthProvider para que esté disponible en toda la app.
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ResenaService()),
        ],
        child: const MyApp(),
      ),
    );

// Define el widget principal de la aplicación (es estático, no cambia).
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor del widget.

  // Método que construye y devuelve la interfaz visual de la app.
  @override
  Widget build(BuildContext context) {
    // Retorna MaterialApp, el widget base para una app con Material Design.
    return MaterialApp(
      // Oculta la cinta de "Debug" en la esquina.
      debugShowCheckedModeBanner: false,

      // --- MODIFICADO ---
      // Título de la app para el sistema operativo.
      title: 'MovieMood', // Actualizado de 'Login App'
      // --- MODIFICADO ---
      // Define el tema visual (oscuro, para que coincida con tu app).
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kDarkBackground,
        primaryColor: kMaroonColor,
        // Define el esquema de colores principal
        colorScheme: const ColorScheme.dark(
          primary: kMaroonColor,
          secondary: kGoldColor,
          background: kDarkBackground,
          onSecondary: Colors.black, // Color para texto sobre 'secondary'
        ),
        // Tema para los botones elevados (como el de 'Publicar Reseña')
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kGoldColor,
            foregroundColor: kDarkBackground,
          ),
        ),
        // Tema para la barra de navegación
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

      // --- MODIFICADO ---
      // Establece AuthCheckScreen como la pantalla de inicio.
      // Esta pantalla decidirá si muestra el Login o pide la huella.
      home: const AuthCheckScreen(),
    );
  }
}
