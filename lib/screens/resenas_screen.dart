import 'dart:io';
import 'package:flutter/material.dart';
import 'resena_detalle_screen.dart';
import '../services/resena_repositoy.dart'; // Importamos el servicio de reseñas
import '../models/resena_model.dart'; // Importamos el modelo de Resena

// --- Convertimos a StatefulWidget para manejar el estado de carga de datos ---
class ResenasScreen extends StatefulWidget {
  const ResenasScreen({super.key});

  @override
  State<ResenasScreen> createState() => _ResenasScreenState();
}

class _ResenasScreenState extends State<ResenasScreen> {
  // --- Fuente de Datos ---
  // Ahora es un Future que obtendrá la lista de reseñas desde la BD.
  late Future<List<Resena>> _listaDeResenasFuture;
  final ResenaService _resenaService = ResenaService();

  @override 
  void initState() {
    super.initState();
    // Iniciamos la carga de datos cuando el widget se crea.
    _loadResenas();
  }

  void _loadResenas() {
    setState(() {
      _listaDeResenasFuture = _resenaService.getAllResenas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      // --- Barra de Aplicación (AppBar) ---
      appBar: AppBar(
        title: const Text('Reseñas Publicadas'),
        backgroundColor: const Color(0xFF8B2E41), // Color corporativo.
        foregroundColor: Colors.white,
        elevation: 0, // Sin sombra.
        actions: [
          // Agregamos un botón para recargar las reseñas
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar reseñas',
            onPressed: _loadResenas,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar reseña',
            onPressed: () => print('Botón de búsqueda presionado'),
          ),
        ],
      ),
      // --- Cuerpo de la Pantalla ---
      body: CustomScrollView(
        slivers: <Widget>[
          // 1. Widget del encabezado (Banner + Títulos).
          const _HeaderResenas(),

          // 2. Usamos un FutureBuilder para construir la lista de reseñas.
          FutureBuilder<List<Resena>>(
            future: _listaDeResenasFuture,
            builder: (context, snapshot) {
              // --- Caso 1: Cargando datos ---
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // --- Caso 2: Error al cargar ---
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Error al cargar las reseñas: ${snapshot.error}',
                    ),
                  ),
                );
              }

              // --- Caso 3: No hay datos ---
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Aún no hay reseñas publicadas.')),
                );
              }

              // --- Caso 4: Datos cargados correctamente ---
              final listaDeResenas = snapshot.data!;
              return SliverList.builder(
                itemCount: listaDeResenas.length,
                itemBuilder: (context, index) {
                  final resena = listaDeResenas[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResenaDetalleScreen(
                              idResena: resena.idResena!, // Pasamos el ID
                              idUserResena: resena.idUser, // ¡NUEVO! Pasamos el ID del autor
                              titulo: resena.titulo,
                              critica: resena.critica,
                              calificacion: resena.calificacion.toDouble(),
                              imagenAsset: resena.imageUrl ?? '',
                            ),
                          ),
                        );
                      },
                      child: ResenaCard(
                        titulo: resena.titulo,
                        critica: resena.critica,
                        calificacion: resena.calificacion.toDouble(),
                        imagenAsset: resena.imageUrl ?? '',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- WIDGET PRIVADO: Encabezado de la pantalla ---
// (Tu código original)
class _HeaderResenas extends StatelessWidget {
  const _HeaderResenas();

  @override
  Widget build(BuildContext context) {
    // SliverToBoxAdapter permite usar un widget normal (como Column)
    // dentro de un CustomScrollView.
    return SliverToBoxAdapter(
      child: Column(
        children: [
          // --- Banner de Imagen de fondo ---
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/image1.jpg',
                ), // Carga imagen local.
                fit: BoxFit.cover, // La imagen cubre todo el contenedor.
              ),
            ),
          ),

          // --- Título principal ---
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
            child: Text(
              'Explora el mundo del cine',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
            ),
          ),

          // --- Subtítulo ---
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 20.0),
            child: Text(
              'Las últimas opiniones de nuestros críticos',
              style: TextStyle(color: Colors.white70, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widget reutilizable para cada Tarjeta de Reseña ---
// (Tu código original)
class ResenaCard extends StatelessWidget {
  final String titulo;
  final String critica;
  final double calificacion;
  final String imagenAsset; // Recibe la ruta de la imagen local.

  const ResenaCard({
    Key? key,
    required this.titulo,
    required this.critica,
    required this.calificacion,
    required this.imagenAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C2C2E),
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior:
          Clip.antiAlias, // Recorta el contenido a la forma de la tarjeta.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Imagen de la Película ---
          // --- LÓGICA CORREGIDA PARA CARGAR IMAGEN ---
          // Decide si cargar desde assets o desde un archivo del dispositivo.
          imagenAsset.startsWith('assets/')
              ? Image.asset(
                  imagenAsset,
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                )
              : Image.file(
                  File(imagenAsset),
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                ),
          // --- Contenido de Texto ---
          // Expanded permite que la columna de texto ocupe el espacio restante.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // El título puede expandirse si es largo.
                      Expanded(
                        child: Text(
                          titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // --- Calificación con Estrella ---
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            calificacion.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // --- Crítica de la Película ---
                  Text(
                    critica,
                    maxLines: 4, // Limita el texto a 3 líneas.
                    overflow: TextOverflow
                        .ellipsis, // Añade "..." si el texto es muy largo.
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4, // Espaciado entre líneas.
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para mostrar en caso de error de carga de imagen.
  Widget _buildErrorImage() {
    return Container(
      width: 100,
      height: 150,
      color: Colors.grey[800],
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white54,
        size: 40,
      ),
    );
  }
}
