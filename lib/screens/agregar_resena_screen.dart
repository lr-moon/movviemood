import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../models/resena_model.dart';
import '../models/auth_provider.dart';
import '../services/resena_repositoy.dart';

// Colores principales de la aplicación
const Color kDarkBackground = Color(0xFF1C1C1E); // Fondo oscuro principal
const Color kMaroonColor = Color(
  0xFF8B1E3F,
); // Color vino para AppBar y acentos
const Color kGoldColor = Color(0xFFD4AF37); // Dorado para botones y estrellas
const Color kLightDark = Color(0xFF2C2C2E); // Gris oscuro para tarjetas

/// Pantalla para crear y publicar reseñas de películas/series
class AgregarResenaScreen extends StatelessWidget {
  const AgregarResenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBackground,
      appBar: AppBar(
        backgroundColor: kMaroonColor,
        elevation: 10, // Sombra pronunciada para dar profundidad
        shadowColor: Colors.black.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ), // Bordes redondeados en la parte inferior
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Regresa a la pantalla anterior
          },
        ),
        title: const Text(
          'Agregar Reseña',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // Permite scroll cuando el teclado aparece
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado decorativo con icono y texto motivacional
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.movie_filter_sharp,
                      color: kGoldColor.withOpacity(0.8),
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '¿Qué te pareció?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Comparte tu opinión con la comunidad',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const ReviewForm(), // Widget del formulario principal
            ],
          ),
        ),
      ),
    );
  }
}

/// Formulario con estado que maneja toda la lógica de creación de reseñas
class ReviewForm extends StatefulWidget {
  const ReviewForm({super.key});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey =
      GlobalKey<FormState>(); // Clave para validación del formulario

  // Controladores para capturar el texto de cada campo
  final TextEditingController _movieNameController = TextEditingController();
  final TextEditingController _reviewTitleController = TextEditingController();
  final TextEditingController _reviewContentController =
      TextEditingController();

  int _rating = 0; // Calificación de 0-5, donde 0 significa sin calificar
  bool _isLoading =
      false; // Bandera para mostrar indicador de carga durante el envío
  File? _imageFile; // Archivo de imagen seleccionado, null si no hay imagen
  final ImagePicker _picker =
      ImagePicker(); // Instancia del selector de imágenes

  /// Muestra un menú modal inferior con dos opciones: galería o cámara
  Future<void> _showImageSourceSelection(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: kLightDark, // Fondo oscuro que combina con el tema
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              // Opción: Seleccionar de galería
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white70),
                title: const Text(
                  'Seleccionar de la Galería',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _pickImage(ImageSource.gallery); // Abre la galería
                  Navigator.of(context).pop(); // Cierra el modal
                },
              ),
              // Opción: Tomar foto con cámara
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.white70),
                title: const Text(
                  'Tomar una Foto',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _pickImage(ImageSource.camera); // Abre la cámara
                  Navigator.of(context).pop(); // Cierra el modal
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Permite al usuario seleccionar una imagen desde galería o cámara
  /// [source] - Origen de la imagen (gallery o camera)
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality:
          80, // Comprime al 80% para reducir tamaño sin perder mucha calidad
    );

    if (pickedFile != null) {
      // La imagen seleccionada está en una ubicación temporal del sistema
      // Debe copiarse a un directorio permanente antes de usarse
      final permanentImagePath = await _saveImagePermanently(
        File(pickedFile.path),
      );

      if (permanentImagePath == null) return; // Si hubo error, no continúa

      setState(
        () => _imageFile = File(permanentImagePath),
      ); // Actualiza UI con la nueva imagen
    }
  }

  /// Copia una imagen desde la ubicación temporal del sistema a un directorio permanente
  /// Las imágenes del ImagePicker son temporales y el sistema puede eliminarlas en cualquier momento
  /// Esta función garantiza que la imagen persista hasta que el usuario decida eliminarla
  /// [tempImage] - Archivo temporal que devuelve ImagePicker
  /// Retorna la ruta permanente de la imagen o null si ocurre un error
  Future<String?> _saveImagePermanently(File tempImage) async {
    try {
      // Obtiene el directorio de documentos de la aplicación (persiste entre sesiones)
      final appDir = await getApplicationDocumentsDirectory();

      // Genera un nombre único usando timestamp en milisegundos + extensión original
      // Ejemplo: 1699564823456.jpg
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${p.extension(tempImage.path)}';

      // Construye la ruta completa del nuevo archivo
      final newImage = File(p.join(appDir.path, fileName));

      // Copia el archivo temporal a la ubicación permanente
      await tempImage.copy(newImage.path);

      return newImage.path; // Devuelve la ruta permanente
    } catch (e) {
      // Si el widget todavía está montado, muestra el error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la imagen: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return null;
    }
  }

  /// Valida todos los campos del formulario y envía la reseña a la base de datos
  /// Realiza tres validaciones críticas antes del envío:
  /// 1. Campos de texto completos (validados por el FormState)
  /// 2. Calificación seleccionada (rating > 0)
  /// 3. Imagen seleccionada (imageFile != null)
  Future<void> _submitReview() async {
    // Validación 1: Verifica que todos los TextFormField estén completos
    if (!_formKey.currentState!.validate()) return;

    // Validación 2: Verifica que el usuario haya dado una calificación
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una calificación.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validación 3: Verifica que se haya seleccionado una imagen
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una imagen.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true); // Activa el indicador de carga

    try {
      // Obtiene el ID del usuario autenticado desde el provider
      // listen: false porque no necesitamos reconstruir el widget si cambia
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;

      if (userId == null) {
        throw Exception('No se pudo obtener el ID del usuario.');
      }

      // La imagen ya está en una ubicación permanente gracias a _saveImagePermanently
      final imagePath = _imageFile!.path;

      // Crea el objeto Resena con todos los datos capturados
      final newReview = Resena(
        idUser: userId, // ID del usuario que crea la reseña
        titulo: _reviewTitleController.text, // Título de la reseña
        critica: _reviewContentController.text, // Contenido completo
        calificacion: _rating, // Calificación de 1-5
        imageUrl: imagePath, // Ruta local de la imagen
      );

      // Inserta la reseña en la base de datos usando el servicio
      await Provider.of<ResenaService>(
        context,
        listen: false,
      ).insertResena(newReview);

      // Muestra mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Reseña publicada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );

      // Cierra la pantalla y regresa a la anterior
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Captura cualquier error durante el proceso y lo muestra al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al publicar la reseña: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Desactiva el indicador de carga sin importar si hubo éxito o error
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Construye un campo de texto estilizado con validación automática
  /// [label] - Etiqueta que aparece arriba del campo
  /// [hint] - Texto de sugerencia dentro del campo
  /// [icon] - Icono opcional al inicio del campo
  /// [controller] - Controlador para capturar y manejar el texto
  /// [maxLines] - Número de líneas visibles (1 para campo simple, más para textarea)
  Widget _buildTextField({
    required String label,
    required String hint,
    IconData? icon,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta del campo
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        // Campo de texto con decoración personalizada
        TextFormField(
          maxLines: maxLines,
          controller: controller,
          style: const TextStyle(
            color: Colors.black87,
          ), // Texto negro para contraste con fondo blanco
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black45),
            filled: true,
            fillColor: Colors.white, // Fondo blanco para el campo
            prefixIcon: icon != null
                ? Icon(icon, color: kMaroonColor.withOpacity(0.7))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide.none, // Sin bordes, solo el fondo
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 20.0,
            ),
          ),
          // Validador que se ejecuta cuando se llama a _formKey.currentState!.validate()
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio';
            }
            return null; // null significa que el campo es válido
          },
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  /// Construye el widget de selección de imagen con borde punteado
  /// Muestra una imagen preview si ya se seleccionó, o un placeholder con instrucciones
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sube una Imagen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        // GestureDetector para capturar el tap y abrir el selector
        GestureDetector(
          onTap: () => _showImageSourceSelection(context),
          child: DottedBorder(
            // Borde punteado decorativo
            color: Colors.white70,
            strokeWidth: 2,
            dashPattern: const [
              6,
              3,
            ], // Patrón de guiones: 6px línea, 3px espacio
            borderType: BorderType.RRect,
            radius: const Radius.circular(15),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kLightDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              // Muestra placeholder o imagen según el estado
              child: _imageFile == null
                  ? const Center(
                      // Placeholder cuando no hay imagen
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.white70,
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Toca para seleccionar una imagen',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      // Preview de la imagen seleccionada
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit
                            .cover, // Cubre todo el espacio manteniendo proporción
                        width: double.infinity,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  /// Construye el sistema de calificación interactivo con 5 estrellas
  /// Al tocar una estrella, se establece la calificación de 1 a 5
  /// Las estrellas se llenan visualmente según el rating actual
  Widget _buildStarRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tu Calificación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        // Fila con 5 estrellas generadas dinámicamente
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                // Muestra estrella llena si el índice es menor que el rating actual
                // Ejemplo: si _rating = 3, muestra llenas las estrellas 0, 1, 2
                index < _rating ? Icons.star : Icons.star_border,
                size: 40,
              ),
              color: kGoldColor,
              onPressed: () {
                setState(() {
                  _rating = index + 1; // Asigna rating de 1 a 5 (índice + 1)
                });
              },
            );
          }),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Asocia el formulario con la clave de validación
      child: Column(
        children: [
          // Campo 1: Nombre de la película o serie
          _buildTextField(
            label: 'Nombre de la Película/Serie',
            hint: 'Ej: Oppenheimer',
            icon: Icons.movie,
            controller: _movieNameController,
          ),

          // Campo 2: Título corto de la reseña
          _buildTextField(
            label: 'Título de tu Reseña',
            hint: 'Ej: Una obra maestra visual',
            icon: Icons.title,
            controller: _reviewTitleController,
          ),

          // Campo 3: Contenido completo de la reseña (multilinea)
          _buildTextField(
            label: 'Tu Reseña Completa',
            hint: 'Escribe tu opinión detallada aquí...',
            icon: Icons.rate_review,
            maxLines: 5, // Campo más grande para texto largo
            controller: _reviewContentController,
          ),

          // Selector de imagen
          _buildImagePicker(),

          // Sistema de calificación por estrellas
          _buildStarRating(),

          // Botón principal para publicar la reseña
          SizedBox(
            width: double.infinity, // Ocupa todo el ancho disponible
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : _submitReview, // Desactiva el botón durante la carga
              style: ElevatedButton.styleFrom(
                backgroundColor: kGoldColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              // Muestra spinner de carga o texto según el estado
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: kDarkBackground),
                    )
                  : const Text(
                      'Publicar Reseña',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kDarkBackground,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
