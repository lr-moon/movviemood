// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usuario _$UsuarioFromJson(Map<String, dynamic> json) {
  return Usuario(
    idUser: (json['id_user'] as num?)?.toInt(),
    email: json['email'] as String,
    contrasena: json['contrasena'] as String,
  );
}

Map<String, dynamic> _$UsuarioToJson(Usuario instance) => <String, dynamic>{
  'id_user': instance.idUser,
  'email': instance.email,
  'contrasena': instance.contrasena,
};
