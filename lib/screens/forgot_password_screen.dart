import 'package:flutter/material.dart';

// --- Definición del Widget de la Pantalla de Olvido de Contraseña ---
// Es un StatelessWidget porque la pantalla no necesita gestionar ningún estado interno
// que cambie dinámicamente. Su contenido es estático.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  // --- Método build ---
  // Construye la interfaz de usuario del widget.
  Widget build(BuildContext context) {
    // Scaffold proporciona la estructura visual básica.
    return Scaffold(
      backgroundColor: const Color(
        0xFF1C1C1E,
      ), // Mismo fondo oscuro para consistencia.
      // SafeArea evita que la UI se superponga con elementos del sistema.
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // --- Encabezado ---
            // Este contenedor es visualmente idéntico al de las otras pantallas
            // para mantener una experiencia de usuario coherente.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF8B2E41), // Color vino/rojizo corporativo.
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_filter, color: Colors.white, size: 40),
                  const SizedBox(width: 12),
                  const Text(
                    'MovieMood',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ],
              ),
            ),

            // --- Formulario de Recuperación ---
            // Expanded ocupa el espacio restante en la pantalla.
            Expanded(
              child: Center(
                // SingleChildScrollView asegura que el contenido sea desplazable
                // si el teclado cubre parte de la pantalla.
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Título principal de la pantalla.
                      const Text(
                        'Recuperar Contraseña',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Texto de instrucción para el usuario.
                      const Text(
                        'Ingresa tu correo electrónico y te enviaremos un enlace para restablecerla.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16.0),
                      ),
                      const SizedBox(height: 32.0),

                      // --- Campo de texto para el Email ---
                      TextField(
                        keyboardType: TextInputType
                            .emailAddress, // Teclado optimizado para email.
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Correo electrónico',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          // Icono al inicio del campo para mayor claridad visual.
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // --- Botón de Enviar ---
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          // Sombra para dar un efecto de elevación.
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFD4AF37,
                            ), // Color dorado.
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: () {
                            print('Enlace de recuperación enviado');
                            // Cierra la pantalla actual para regresar a la de login.
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Enviar Enlace',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // --- Botón para volver al Login ---
                      TextButton(
                        onPressed: () {
                          // Cierra esta pantalla y regresa a la anterior.
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Volver a Iniciar Sesión',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
