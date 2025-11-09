// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Gestiona la conexión a la base de datos SQLite de la aplicación.
///
/// Utiliza un patrón Singleton para garantizar una única instancia de la base de datos
/// en toda la aplicación, evitando conflictos y fugas de memoria.
class DatabaseService {
  static const _databaseName = "moviemood.db";
  static const _databaseVersion = 1;

  // --- Implementación del Singleton ---

  // Constructor privado para evitar la instanciación directa.
  DatabaseService._privateConstructor();

  /// La única instancia de la clase DatabaseService.
  static final DatabaseService instance = DatabaseService._privateConstructor();

  // Referencia única a la base de datos para toda la app.
  static Database? _database;

  /// Getter para la base de datos.
  ///
  /// Si la base de datos ya está inicializada, la devuelve.
  /// Si no, la inicializa y luego la devuelve.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // --- Inicialización de la Base de Datos ---

  /// Abre la conexión a la base de datos y la crea si no existe.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Ejecuta el script SQL para crear la estructura inicial de la base de datos.
  Future<void> _onCreate(Database db, int version) async {
    final String schemaScript = await rootBundle.loadString(
      'lib/services/db_schema.sql',
    );
    // LOG: Imprimimos un mensaje para saber que la BD se está creando.
    //print("--- Creando base de datos desde db_schema.sql ---");
    // El script contiene múltiples sentencias. Debemos separarlas y ejecutarlas una por una.
    for (final statement in schemaScript.split(';')) {
      // Nos aseguramos de no ejecutar sentencias vacías (por ejemplo, después del último ';').
      if (statement.trim().isNotEmpty) {
        await db.execute(statement);
      }
    }
    //print("--- Base de datos creada y poblada exitosamente. ---");
  }
}
