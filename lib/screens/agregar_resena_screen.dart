import 'dart:io'; // Importa dart:io para manejar el tipo 'File'
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importa el paquete de image_picker
import 'package:dotted_border/dotted_border.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../models/resena_model.dart';
import '../models/auth_provider.dart';
import '../services/resena_repositoy.dart';

// --- Definición de los colores de tu app ---
const Color kDarkBackground = Color(0xFF1C1C1E);
const Color kMaroonColor = Color(0xFF8B1E3F);
const Color kGoldColor = Color(0xFFD4AF37);
const Color kLightDark = Color(0xFF2C2C2E);

// --- Pantalla Principal: "Agregar Reseña" ---
class AgregarResenaScreen extends StatelessWidget {
  const AgregarResenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBackground,
      appBar: AppBar(
        backgroundColor: kMaroonColor,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Título creativo ---
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

              // --- Formulario de Reseña ---
              const ReviewForm(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Widget del Formulario (Stateful) ---
class ReviewForm extends StatefulWidget {
  const ReviewForm({super.key});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _movieNameController = TextEditingController();
  final TextEditingController _reviewTitleController = TextEditingController();
  final TextEditingController _reviewContentController =
      TextEditingController();
  int _rating = 0;
  bool _isLoading = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // --- NUEVA FUNCIÓN (PUNTO 5): MUESTRA EL MENÚ DE OPCIONES ---
  Future<void> _showImageSourceSelection(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      // Se añaden estilos para que combine con tu app oscura
      backgroundColor: kLightDark,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white70),
                title: const Text(
                  'Seleccionar de la Galería',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop(); // Cierra el menú
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.white70),
                title: const Text(
                  'Tomar una Foto',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop(); // Cierra el menú
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Permite al usuario seleccionar una imagen de la galería o tomar una foto.
  /// La imagen seleccionada se copia a un directorio permanente para evitar que se pierda.
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      // Guarda la imagen en una ubicación permanente y actualiza el estado.
      final permanentImagePath = await _saveImagePermanently(
        File(pickedFile.path),
      );
      if (permanentImagePath == null)
        return; // Si hubo un error, no continuamos.

      setState(() => _imageFile = File(permanentImagePath));
    }
  }

  /// Guarda la imagen temporal en un directorio permanente y devuelve la ruta.
  Future<String?> _saveImagePermanently(File tempImage) async {
    try {
      // 1. Obtener el directorio de documentos de la aplicación.
      final appDir = await getApplicationDocumentsDirectory();
      // 2. Crear un nombre de archivo único para evitar colisiones.
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${p.extension(tempImage.path)}';
      // 3. Crear la ruta de destino permanente.
      final newImage = File(p.join(appDir.path, fileName));
      // 4. Copiar el archivo desde la ruta temporal a la permanente.
      await tempImage.copy(newImage.path);
      // 5. Devolver la nueva ruta permanente.
      return newImage.path;
    } catch (e) {
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

  /// Procesa y guarda la reseña completa.
  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una calificación.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una imagen.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Obtener el ID del usuario desde AuthProvider.
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      if (userId == null)
        throw Exception('No se pudo obtener el ID del usuario.');

      // 2. La imagen ya está en una ruta permanente. Solo obtenemos la ruta.
      final imagePath = _imageFile!.path;

      // 3. Crear el objeto Resena.
      final newReview = Resena(
        idUser: userId,
        titulo: _reviewTitleController.text,
        critica: _reviewContentController.text,
        calificacion: _rating,
        imageUrl: imagePath,
      );

      // 4. Insertar en la base de datos usando ResenaService.
      await Provider.of<ResenaService>(
        context,
        listen: false,
      ).insertResena(newReview);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Reseña publicada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al publicar la reseña: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Widget para construir los campos de texto ---
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          maxLines: maxLines,
          controller: controller,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black45),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: icon != null
                ? Icon(icon, color: kMaroonColor.withOpacity(0.7))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 20.0,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  // --- WIDGET PARA MOSTRAR EL SELECTOR DE IMAGEN ---
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
        GestureDetector(
          // --- CAMBIO (PUNTO 5): LLAMA A LA FUNCIÓN DE SELECCIÓN ---
          onTap: () => _showImageSourceSelection(context),
          child: DottedBorder(
            color: Colors.white70,
            strokeWidth: 2,
            dashPattern: const [6, 3],
            borderType: BorderType.RRect,
            radius: const Radius.circular(15),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kLightDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: _imageFile == null
                  ? const Center(
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
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
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

  // --- Widget para construir las estrellas de calificación ---
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                size: 40,
              ),
              color: kGoldColor,
              onPressed: () {
                setState(() {
                  _rating = index + 1;
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
      key: _formKey,
      // --- CÓDIGO CORREGIDO: SIN DUPLICADOS Y EN ORDEN LÓGICO ---
      child: Column(
        children: [
          _buildTextField(
            label: 'Nombre de la Película/Serie',
            hint: 'Ej: Oppenheimer',
            icon: Icons.movie,
            controller: _movieNameController,
          ),
          _buildTextField(
            label: 'Título de tu Reseña',
            hint: 'Ej: Una obra maestra visual',
            icon: Icons.title,
            controller: _reviewTitleController,
          ),
          _buildTextField(
            label: 'Tu Reseña Completa',
            hint: 'Escribe tu opinión detallada aquí...',
            icon: Icons.rate_review,
            maxLines: 5,
            controller: _reviewContentController,
          ),

          // El selector de imagen va después de los campos de texto
          _buildImagePicker(),

          // La calificación va después de la imagen
          _buildStarRating(),

          // --- Botón de Publicar ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGoldColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
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
