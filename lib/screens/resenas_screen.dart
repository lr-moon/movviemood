import 'dart:io';
import 'package:flutter/material.dart';
import 'resena_detalle_screen.dart';
import '../services/resena_repositoy.dart'; // Importamos el servicio de reseñas
import '../models/resena_model.dart'; // Importamos el modelo de Resena

class ResenasScreen extends StatefulWidget {
  const ResenasScreen({super.key});

  @override
  State<ResenasScreen> createState() => _ResenasScreenState();
}

class _ResenasScreenState extends State<ResenasScreen> {
  // --- Fuente de Datos ---
  late Future<List<Resena>> _listaDeResenasFuture;
  final ResenaService _resenaService = ResenaService();

  // --- Variables de estado para la Búsqueda ---
  bool _isSearching = false; // Controla si la barra de búsqueda está visible
  final TextEditingController _searchController = TextEditingController();
  List<Resena> _allResenas = []; // Guarda la lista completa
  List<Resena> _filteredResenas = []; // Guarda la lista filtrada

  @override
  void initState() {
    super.initState();
    // Iniciamos la carga de datos.
    _loadResenas();

    // --- Listener para el campo de búsqueda ---
    // Cada vez que el usuario escribe, se llama a _filterResenas
    _searchController.addListener(() {
      _filterResenas(_searchController.text);
    });
  }

  void _loadResenas() {
    setState(() {
      // Reiniciamos las listas al recargar
      _allResenas = [];
      _filteredResenas = [];
      _listaDeResenasFuture = _resenaService.getAllResenas();
    });
  }

  // --- Método para filtrar la lista ---
  void _filterResenas(String query) {
    // Obtenemos la consulta de búsqueda en minúsculas
    final String searchQuery = query.toLowerCase();

    setState(() {
      // Filtramos la lista completa (_allResenas)
      _filteredResenas = _allResenas.where((resena) {
        // Comparamos el título de la reseña (también en minúsculas)
        final String titulo = resena.titulo.toLowerCase();
        return titulo.contains(searchQuery);
      }).toList();
    });
  }

  // --- Método para construir el AppBar dinámicamente ---
  AppBar _buildAppBar() {
    if (_isSearching) {
      // --- AppBar de Búsqueda (cuando _isSearching es true) ---
      return AppBar(
        backgroundColor: const Color(
          0xFF2C2C2E,
        ), // Un color más oscuro para la búsqueda
        leading: const Icon(Icons.search, color: Colors.white70),
        title: TextField(
          controller: _searchController,
          autofocus: true, // Abre el teclado automáticamente
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Buscar por título de película...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none, // Sin línea debajo
          ),
        ),
        actions: [
          // Botón para limpiar y cerrar la búsqueda
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Cerrar búsqueda',
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear(); // Limpia el texto
                // _filterResenas("") se llamará automáticamente por el listener
              });
            },
          ),
        ],
      );
    } else {

      return AppBar(
        title: const Text('Reseñas Publicadas'),
        backgroundColor: const Color(0xFF8B2E41),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar reseñas',
            onPressed: _loadResenas,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar reseña',
            // --- Al presionar, activa el estado de búsqueda ---
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      // --- Usamos el método para el AppBar ---
      appBar: _buildAppBar(),

      body: CustomScrollView(
        slivers: <Widget>[
          // 1. Widget del encabezado (Banner + Títulos).
          // Ocultamos el header si estamos buscando para dar más espacio
          if (!_isSearching) const _HeaderResenas(),

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

              // --- Lógica de Búsqueda ---
              // Si la lista _allResenas está vacía, la llenamos con los datos
              // del snapshot. Esto solo pasa la primera vez o al recargar.
              if (_allResenas.isEmpty) {
                _allResenas = snapshot.data!;
                _filteredResenas = _allResenas;
              }
              // --- FIN MODIFICACIÓN ---

              // --- Manejar "Búsqueda sin resultados" ---
              // Si la lista filtrada está vacía, pero la lista original no,
              // significa que la búsqueda no arrojó resultados.
              if (_filteredResenas.isEmpty && _allResenas.isNotEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No se encontraron reseñas con ese título.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                );
              }

              //  Usamos _filteredResenas ---
              return SliverList.builder(
                itemCount: _filteredResenas.length, // <-- USA LA LISTA FILTRADA
                itemBuilder: (context, index) {
                  final resena =
                      _filteredResenas[index]; // <-- USA LA LISTA FILTRADA
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
                              idResena: resena.idResena!,
                              idUserResena: resena.idUser,
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

// --- Encabezado de la pantalla ---
class _HeaderResenas extends StatelessWidget {
  const _HeaderResenas();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/image1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
class ResenaCard extends StatelessWidget {
  final String titulo;
  final String critica;
  final double calificacion;
  final String imagenAsset;

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
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imagenAsset.startsWith('assets/')
              ? Image.asset(
                  imagenAsset,
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildErrorImage(),
                )
              : Image.file(
                  File(imagenAsset),
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildErrorImage(),
                ),
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
                  Text(
                    critica,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
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
