import 'package:flutter/material.dart';
import '../services/acount_repository.dart';

/// Un `ChangeNotifier` para gestionar el estado de autenticación del usuario.
///
/// Mantiene el estado de carga, si el usuario está autenticado y su ID.
class AuthProvider with ChangeNotifier {
  final AccountRepository _accountRepository = AccountRepository();

  int? _userId;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  // Getters públicos para acceder al estado desde la UI.
  int? get userId => _userId;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  /// Intenta iniciar sesión con las credenciales proporcionadas.
  ///
  /// En caso de éxito, actualiza el estado a "logueado" y almacena el ID del usuario.
  /// Lanza una excepción si el inicio de sesión falla, que puede ser capturada en la UI.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Llama al repositorio, que ahora devolverá el ID del usuario.
      final loggedInUserId = await _accountRepository.login(email, password);
      _userId = loggedInUserId;
      _isLoggedIn = true;
    } catch (e) {
      // En caso de error, resetea el estado.
      _userId = null;
      _isLoggedIn = false;
      rethrow; // Vuelve a lanzar el error para que la UI lo maneje.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}