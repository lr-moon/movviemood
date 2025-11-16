import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/resena_model.dart';
import 'conexion.dart'; // Importamos el servicio de conexión centralizado.

class ResenaService with ChangeNotifier {
  static const String _tableName = 'Resenas';

  // Obtenemos la instancia de la base de datos desde nuestro singleton DatabaseService.
  Future<Database> get database async {
    // Esto asegura que usemos la base de datos 'moviemood.db'
    // y que se cree usando 'db_schema.sql' si no existe.
    return await DatabaseService.instance.database;
  }
 
  /// Inserta una nueva reseña
  Future<int> insertResena(Resena resena) async {
    final db = await database;
    final id = await db.insert(_tableName, resena.toMap());
    notifyListeners();
    return id;
  }

  /// Obtiene todas las reseñas
  Future<List<Resena>> getAllResenas() async {
    final db = await database;
    // Ordenamos por id para que las más nuevas aparezcan primero (opcional).
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'id_resena DESC',
    );

    // LOG: Imprimimos los datos crudos de la BD para depuración.
    debugPrint("--- Datos de reseñas obtenidos de la BD ---");
    debugPrint(maps.toString());
    return maps.map((map) => Resena.fromMap(map)).toList();
  }

  /// Obtiene reseñas por usuario
  Future<List<Resena>> getResenasByUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id_user = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => Resena.fromMap(map)).toList();
  }

  /// Actualiza una reseña existente
  Future<int> updateResena(Resena resena) async {
    final db = await database;
    final count = await db.update(
      _tableName,
      resena.toMap(),
      where: 'id_resena = ?',
      whereArgs: [resena.idResena],
    );
    notifyListeners();
    return count;
  }

  /// Elimina una reseña
  Future<int> deleteResena(int idResena) async {
    final db = await database;
    final count = await db.delete(
      _tableName,
      where: 'id_resena = ?',
      whereArgs: [idResena],
    );
    notifyListeners();
    return count;
  }

  /// Elimina todas las reseñas (opcional)
  Future<void> clearResenas() async {
    final db = await database;
    await db.delete(_tableName); 
    notifyListeners();
  }
}
