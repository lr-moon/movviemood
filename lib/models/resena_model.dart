import 'package:json_annotation/json_annotation.dart';

part 'resena_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Resena {
  @JsonKey(name: 'id_resena')
  final int? idResena; // INTEGER PRIMARY KEY

  @JsonKey(name: 'id_user')
  final int idUser; // FOREIGN KEY, NOT NULL

  @JsonKey(name: 'titulo')
  final String titulo; // TEXT NOT NULL

  @JsonKey(name: 'critica')
  final String critica; // TEXT NOT NULL

  @JsonKey(name: 'calificacion')
  final int calificacion; // INTEGER NOT NULL CHECK(1 <= calificacion <= 5)

  @JsonKey(name: 'imagen_url')
  final String? imageUrl; // TEXT (Opcional)

  Resena({
    this.idResena,
    required this.idUser,
    required this.titulo,
    required this.critica,
    required this.calificacion,
    this.imageUrl,
  }) : assert(
          calificacion >= 1 && calificacion <= 5,
          'La calificación debe estar entre 1 y 5.',
        );

  /// --- Métodos de serialización JSON ---
  factory Resena.fromJson(Map<String, dynamic> json) => _$ResenaFromJson(json);
  Map<String, dynamic> toJson() => _$ResenaToJson(this);

  /// --- Métodos para SQLite ---
  factory Resena.fromMap(Map<String, dynamic> map) => Resena(
        idResena: map['id_resena'] as int?,
        idUser: map['id_user'] as int,
        titulo: map['titulo'] as String,
        critica: map['critica'] as String,
        calificacion: map['calificacion'] as int,
        imageUrl: map['imagen_url'] as String?,
      );
 
  Map<String, dynamic> toMap() => {
        'id_resena': idResena,
        'id_user': idUser,
        'titulo': titulo,
        'critica': critica,
        'calificacion': calificacion,
        'imagen_url': imageUrl,
      };
}
