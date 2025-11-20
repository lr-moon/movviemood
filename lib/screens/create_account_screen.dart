import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_provider.dart';
import '../services/acount_repository.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Variables de visibilidad
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Variables de estado para errores
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Expresiones regulares para validación
  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );
  
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'
  );

  @override
  void initState() {
    super.initState();
    // Listeners para validación en tiempo real
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Validación de email en tiempo real
  void _validateEmail() {
    if (emailController.text.isEmpty) {
      setState(() {
        _emailError = null;
      });
      return;
    }

    if (!_emailRegex.hasMatch(emailController.text)) {
      setState(() {
        _emailError = 'Por favor, ingresa un correo electrónico válido';
      });
    } else {
      setState(() {
        _emailError = null;
      });
    }
  }

  // Validación de contraseña en tiempo real
  void _validatePassword() {
    if (passwordController.text.isEmpty) {
      setState(() {
        _passwordError = null;
      });
      return;
    }

    if (passwordController.text.length < 8) {
      setState(() {
        _passwordError = 'La contraseña debe tener al menos 8 caracteres';
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }

    // También validar la confirmación cuando cambia la contraseña principal
    _validateConfirmPassword();
  }

  // Validación de confirmación de contraseña en tiempo real
  void _validateConfirmPassword() {
    if (confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = null;
      });
      return;
    }

    if (confirmPasswordController.text != passwordController.text) {
      setState(() {
        _confirmPasswordError = 'Las contraseñas no coinciden';
      });
    } else {
      setState(() {
        _confirmPasswordError = null;
      });
    }
  }

  // Función para validar todos los campos antes del registro
  bool _validateAllFields() {
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();

    return _emailError == null && 
           _passwordError == null && 
           _confirmPasswordError == null &&
           emailController.text.isNotEmpty &&
           passwordController.text.isNotEmpty &&
           confirmPasswordController.text.isNotEmpty;
  }

  // Función que muestra los requisitos de la contraseña
  Widget _buildPasswordRequirements() {
    final password = passwordController.text;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'La contraseña debe contener:',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        _buildRequirementLine('• Mínimo 8 caracteres', password.length >= 8),
        _buildRequirementLine('• Al menos una mayúscula', RegExp(r'[A-Z]').hasMatch(password)),
        _buildRequirementLine('• Al menos una minúscula', RegExp(r'[a-z]').hasMatch(password)),
        _buildRequirementLine('• Al menos un número', RegExp(r'\d').hasMatch(password)),
        _buildRequirementLine('• Al menos un carácter especial (@\$!%*?&)', 
            RegExp(r'[@$!%*?&]').hasMatch(password)),
      ],
    );
  }

  Widget _buildRequirementLine(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? Colors.green : Colors.grey,
          size: 12,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: isMet ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _onRegisterPressed() async {
    // Validar todos los campos antes de proceder
    if (!_validateAllFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los errores en el formulario.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.register(
        emailController.text.trim().toLowerCase(), // Normalizar email
        passwordController.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on RegistrationException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Encabezado (sin cambios)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF8B2E41),
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
            
            // Formulario de Registro
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        'Crear Cuenta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      
                      // Campo de Correo electrónico
                      const Text(
                        'Correo electrónico',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'ejemplo@correo.com',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          errorText: _emailError,
                          errorStyle: const TextStyle(color: Colors.orange),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Campo de Contraseña
                      const Text(
                        'Contraseña',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Contraseña segura',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          errorText: _passwordError,
                          errorStyle: const TextStyle(color: Colors.orange),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Mostrar requisitos de contraseña solo cuando el campo está enfocado o tiene texto
                      if (passwordController.text.isNotEmpty)
                        _buildPasswordRequirements(),
                      const SizedBox(height: 8.0),

                      // Campo de Confirmar Contraseña
                      const Text(
                        'Confirmar Contraseña',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Confirmar contraseña',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          errorText: _confirmPasswordError,
                          errorStyle: const TextStyle(color: Colors.orange),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Botón de Crear Cuenta
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
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
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: (authProvider.isLoading || !_validateAllFields()) 
                              ? null 
                              : _onRegisterPressed,
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Crear Cuenta',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      // Botón para ir a Iniciar Sesión
                      TextButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text(
                          '¿Ya tienes una cuenta? Inicia sesión',
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