import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(PokemonApp());
}

class PokemonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon API',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Explorer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PokemonSearchScreen()),
                );
              },
              child: Text('Buscar Pokémon'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CatFactsScreen()),
                );
              },
              child: Text('Datos de Gatos (Cat Facts)'),
            ),
          ],
        ),
      ),
    );
  }
}

class PokemonSearchScreen extends StatefulWidget {
  @override
  _PokemonSearchScreenState createState() => _PokemonSearchScreenState();
}

class _PokemonSearchScreenState extends State<PokemonSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _pokemonData;
  bool _isLoading = false;

  Future<void> fetchPokemon(String name) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _pokemonData = {
            'name': data['name'],
            'image': data['sprites']['front_default'],
            'height': data['height'],
            'weight': data['weight'],
            'types': (data['types'] as List)
                .map((type) => type['type']['name'])
                .toList(),
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _pokemonData = null;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pokémon no encontrado')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Pokémon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nombre del Pokémon',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => fetchPokemon(_controller.text.toLowerCase()),
              child: Text('Buscar'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : _pokemonData != null
                    ? Column(
                        children: [
                          if (_pokemonData!['image'] != null)
                            Image.network(_pokemonData!['image']),
                          SizedBox(height: 8),
                          Text('Nombre: ${_pokemonData!['name']}',
                              style: TextStyle(fontSize: 18)),
                          Text('Altura: ${_pokemonData!['height']}'),
                          Text('Peso: ${_pokemonData!['weight']}'),
                          Text('Tipos: ${_pokemonData!['types'].join(', ')}'),
                        ],
                      )
                    : Text('Introduce un nombre para buscar'),
          ],
        ),
      ),
    );
  }
}

class CatFactsScreen extends StatefulWidget {
  @override
  _CatFactsScreenState createState() => _CatFactsScreenState();
}

class _CatFactsScreenState extends State<CatFactsScreen> {
  String? _catFact;
  String? _catImageUrl;
  bool _isLoading = false;

  Future<void> fetchCatFactAndImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch Cat Fact
      final factUrl = Uri.parse('https://catfact.ninja/fact');
      final factResponse = await http.get(factUrl);

      // Fetch Cat Image
      final imageUrl = Uri.parse('https://api.thecatapi.com/v1/images/search');
      final imageResponse = await http.get(imageUrl);

      if (factResponse.statusCode == 200 && imageResponse.statusCode == 200) {
        final factData = json.decode(factResponse.body);
        final imageData = json.decode(imageResponse.body);

        setState(() {
          _catFact = factData['fact'];
          _catImageUrl = imageData[0]['url'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _catFact = 'No se pudo obtener el dato.';
          _catImageUrl = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _catFact = 'Error al cargar datos.';
        _catImageUrl = null;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datos e Imágenes de Gatos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      if (_catImageUrl != null)
                        Image.network(
                          _catImageUrl!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      SizedBox(height: 16),
                      if (_catFact != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _catFact!,
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchCatFactAndImage,
              child: Text('Obtener Dato e Imagen'),
            ),
          ],
        ),
      ),
    );
  }
}
