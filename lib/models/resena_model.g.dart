// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resena_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Resena _$ResenaFromJson(Map<String, dynamic> json) {
  return Resena(
    idResena: (json['id_resena'] as num?)?.toInt(),
    idUser: (json['id_user'] as num).toInt(),
    titulo: json['titulo'] as String,
    critica: json['critica'] as String,
    calificacion: (json['calificacion'] as num).toInt(),
    imageUrl: json['imagen_url'] as String?,
  );
}

Map<String, dynamic> _$ResenaToJson(Resena instance) => <String, dynamic>{
  'id_resena': instance.idResena,
  'id_user': instance.idUser,
  'titulo': instance.titulo,
  'critica': instance.critica,
  'calificacion': instance.calificacion,
  'imagen_url': instance.imageUrl,
};
