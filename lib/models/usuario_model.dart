import 'package:json_annotation/json_annotation.dart';

part 'usuario_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Usuario {
  @JsonKey(name: 'id_user')
  final int? idUser; // INTEGER PRIMARY KEY AUTOINCREMENT

  @JsonKey(name: 'email')
  final String email; // TEXT NOT NULL UNIQUE

  @JsonKey(name: 'contrasena')
  final String contrasena; // TEXT NOT NULL

  Usuario({this.idUser, required this.email, required this.contrasena});

  /// JSON Serialization
  factory Usuario.fromJson(Map<String, dynamic> json) =>
      _$UsuarioFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioToJson(this);

  /// Métodos para SQLite (opcional, útiles para BD local)
  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
    idUser: map['id_user'] as int?,
    email: map['email'] as String,
    contrasena: map['contrasena'] as String,
  );

  Map<String, dynamic> toMap() => {
    'id_user': idUser,
    'email': email,
    'contrasena': contrasena,
  };
}
