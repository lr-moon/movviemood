import 'package:flutter_application_1/services/conexion.dart'; // Corregido
import 'package:sqflite/sqflite.dart';
import 'dart:async';

/// Excepción personalizada para errores durante el registro.
class RegistrationException implements Exception {
  final String message;
  RegistrationException(this.message);

  @override
  String toString() => message;
}

/// Excepción personalizada para errores durante el inicio de sesión.
class LoginException implements Exception {
  final String message;
  LoginException(this.message);

  @override
  String toString() => message;
}

/// Repositorio para gestionar las operaciones de la cuenta de usuario.
class AccountRepository {
  // Obtiene la instancia del helper de la base de datos.
  final _dbService = DatabaseService.instance;

  /// Verifica si un usuario ya existe en la base de datos por su email.
  ///
  /// Devuelve `true` si el usuario existe, `false` en caso contrario.
  Future<bool> checkUserExists(String email) async {
    final db = await _dbService.database;
    final result = await db.query(
      'Usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1, // Solo necesitamos saber si existe al menos uno.
    );
    return result.isNotEmpty;
  }

  /// Registra un nuevo usuario en la base de datos.
  ///
  /// Valida si el correo ya existe y lanza una [RegistrationException] si es así.
  /// Recibe [email] y [password] del nuevo usuario.
  Future<void> registerUser(String email, String password) async {
    // 1. Validar si el usuario ya existe ANTES de intentar insertar.
    final bool userExists = await checkUserExists(email);
    if (userExists) {
      throw RegistrationException('El correo electrónico ya está registrado.');
    }
    print("Se paso la vaqlidacion de que el ususariio no existia");
    // 2. Si no existe, proceder con el registro.
    try {
      // Intenta registrar al usuario usando el método del DatabaseHelper.
      print("Se pudo crear la cuenta");
      await _dbService.registerUser(email, password);
    } on DatabaseException catch (e) {
      // Captura otros posibles errores de la base de datos durante la inserción.
      throw RegistrationException(
        'Error al crear la cuenta en la base de datos.',
      );
    }
  }

  /// Valida las credenciales de un usuario para iniciar sesión.
  ///
  /// Lanza un [LoginException] si el usuario no se encuentra o la contraseña es incorrecta.
  /// Devuelve el `id_user` si el login es exitoso.
  Future<int> login(String email, String password) async {
    final db = await _dbService.database;

    // 1. Buscar al usuario por su correo electrónico.
    final List<Map<String, dynamic>> users = await db.query(
      'Usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    // 2. Verificar si el usuario existe.
    if (users.isEmpty) {
      throw LoginException('El usuario no se encuentra registrado.');
    }

    final user = users.first;

    // 3. Verificar si la contraseña coincide.
    if (user['contrasena'] != password) {
      throw LoginException('La contraseña es incorrecta.');
    }
    // 4. Si todo es correcto, devuelve el ID del usuario.
    // Asumimos que la columna de la clave primaria se llama 'id_user'.
    return user['id_user'] as int;
  }
}
