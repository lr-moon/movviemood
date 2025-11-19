import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_provider.dart';
import '../models/resena_model.dart';
import '../services/resena_repositoy.dart';
import 'editar_resena_screen.dart';

// --- Definición de los colores ---
const Color kMaroonColor = Color(0xFF8B2E41);
const Color kGoldColor = Color(0xFFD4AF37);
const Color kLightBackground = Color(0xFFFFFFFF); 
const Color kDarkText = Color(0xFF2d2d2d); 
const Color kSubtleText = Color(0xFF5f5f5f); 

class ResenaDetalleScreen extends StatelessWidget {
  final int idResena;
  final int idUserResena; // ID del usuario que creó la reseña
  final String titulo;
  final String critica;
  final double calificacion;
  final String imagenAsset;

  const ResenaDetalleScreen({
    super.key,
    required this.idResena,
    required this.idUserResena,
    required this.titulo,
    required this.critica,
    required this.calificacion,
    required this.imagenAsset,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenemos el ID del usuario que ha iniciado sesión
    final loggedInUserId = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).userId;
    // Verificamos si el usuario actual es el dueño de la reseña
    final esPropietario = loggedInUserId == idUserResena;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 38, 37, 37),

      appBar: AppBar(
        backgroundColor: kMaroonColor,
        foregroundColor: Colors.white,
        elevation: 10,
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          //  Alineación a la izquierda
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Imagen con Sombra y Altura Fija ---
            Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 15.0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  // --- LÓGICA CORREGIDA PARA CARGAR IMAGEN ---
                  // Decide si cargar desde assets o desde un archivo del dispositivo.
                  child: imagenAsset.startsWith('assets/')
                      ? Image.asset(
                          imagenAsset,
                          height: 350.0,
                          width: MediaQuery.of(context).size.width * 0.85,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildErrorImage(context),
                        )
                      : Image.file(
                          File(imagenAsset),
                          height: 350.0,
                          width: MediaQuery.of(context).size.width * 0.85,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildErrorImage(context),
                        ),
                ),
              ),
            ),

            // --- Contenido de la Reseña ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                //  Alineación a la izquierda
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Sección de Calificación Minimalista ---
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      // Alinear el texto por la base
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Icon(
                          Icons.star,
                          color: kGoldColor,
                          size: 32,
                        ), // Icono más grande
                        const SizedBox(width: 8),
                        // Usamos RichText para dos estilos de texto
                        RichText(
                          text: TextSpan(
                            // Estilo base (para el número grande)
                            style: const TextStyle(
                              color: Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ), // Color de texto oscuro
                              fontSize: 30, // Mucho más grande
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              // Número de calificación
                              TextSpan(text: calificacion.toString()),
                              // Sufijo "/ 10" más pequeño y sutil
                              TextSpan(
                                text: ' / 5.0',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    249,
                                    234,
                                    234,
                                  ), // Color más sutil
                                  fontSize: 18, // Más pequeño
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Título "Crítica Completa" con Icono ---
                  Row(
                    children: [
                      Icon(
                        Icons.notes, // Icono de reseña
                        color: const Color.fromARGB(
                          255,
                          246,
                          244,
                          244,
                        ).withOpacity(0.7),
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Crítica Completa',
                        style: TextStyle(
                          color: const Color.fromARGB(
                            255,
                            252,
                            249,
                            249,
                          ).withOpacity(0.9),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey[300], thickness: 1, height: 20),
                  const SizedBox(height: 10),

                  // --- Texto de la Crítica (Justificado) ---
                  Text(
                    critica,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 16,
                      height: 1.7, // Más interlineado
                    ),
                    // Texto Justificado
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 40), // Espacio al final
                ],
              ),
            ),

            // --- SECCIÓN DE BOTONES DE ACCIÓN (SOLO SI ES PROPIETARIO) ---
            if (esPropietario)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // --- Botón de Editar ---
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit, color: kDarkText),
                        label: const Text(
                          'Editar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          // Creamos el objeto Resena para pasarlo a la pantalla de edición
                          final resenaAEditar = Resena(
                            idResena: idResena,
                            titulo: titulo,
                            critica: critica,
                            calificacion: calificacion.toInt(),
                            imageUrl: imagenAsset,
                            idUser: idUserResena, // Pasamos el idUser correcto
                          );

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditarResenaScreen(resena: resenaAEditar),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGoldColor,
                          foregroundColor: kDarkText,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // --- Botón de Eliminar ---
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
                        ),
                        label: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        onPressed: () async {
                          // Lógica para eliminar con doble confirmación
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirmar Eliminación'),
                              content: const Text(
                                '¿Estás seguro de que quieres eliminar esta reseña? Esta acción no se puede deshacer.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true) {
                            try {
                              await Provider.of<ResenaService>(
                                context,
                                listen: false,
                              ).deleteResena(idResena);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reseña eliminada con éxito.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al eliminar: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para mostrar en caso de error de carga de imagen.
  Widget _buildErrorImage(BuildContext context) {
    return Container(
      height: 350.0,
      width: MediaQuery.of(context).size.width * 0.85,
      color: Colors.grey[800],
      child: const Icon(Icons.movie_filter, color: Colors.grey, size: 80),
    );
  }
}
