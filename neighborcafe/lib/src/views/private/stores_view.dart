import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // Importar url_launcher
import 'dart:convert';

class StoresView extends StatefulWidget {
  const StoresView({super.key});

  @override
  _StoresViewState createState() => _StoresViewState();
}

class _StoresViewState extends State<StoresView> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? loggedinUser; // Cambia a User? para permitir valores nulos
  String? username;

// Lista completa de datos (sin filtrar)
  List<dynamic> _allCardsData = [];
  // Lista de datos filtrados que se mostrarán
  List<dynamic> _filteredCardsData = [];
  // Estado del filtro
  bool _showOnlyOnline = false;

  // Simulación de cargar datos desde JSON
  void _loadData() {
    String jsonString = '''
    [
      { "title": "Card 1", "description": "This is the description of card 1", "online": true, "link": "https://www.facebook.com" },
      { "title": "Card 2", "description": "This is the description of card 2", "online": false, "link": "https://www.example.com/2" },
      { "title": "Card 3", "description": "This is the description of card 3", "online": true, "link": "https://www.example.com/3" }
    ]
    ''';

    final jsonData = json.decode(jsonString);

    setState(() {
      _allCardsData = jsonData;
      _filteredCardsData =
          _allCardsData; // Inicialmente, mostrar todas las cards
    });
  }

  // Función para alternar el filtro de mostrar solo "online"
  void _toggleOnlineFilter() {
    setState(() {
      _showOnlyOnline = !_showOnlyOnline;

      if (_showOnlyOnline) {
        // Filtrar solo las cards que tienen el campo online en true
        _filteredCardsData =
            _allCardsData.where((card) => card['online'] == true).toList();
      } else {
        // Si no se activa el filtro, mostrar todas las cards
        _filteredCardsData = _allCardsData;
      }
    });
  }

  _launchURL(String url) async {
    final Uri _url = Uri.parse('https://flutter.dev');
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url);
    } else {
      throw 'Could not launch $_url';
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _loadData(); // Cargar los datos cuando la pantalla se inicia
  }

  void getCurrentUser() async {
    final user = _auth.currentUser; // No es necesario usar await aquí
    if (user != null) {
      setState(() {
        loggedinUser = user; // Actualiza el estado
      });
      await getUsername(user.uid);
    } else {
      // Manejar caso donde el usuario no está autenticado
      print("No user is currently logged in.");
    }
  }

  // Función para obtener el nombre de usuario desde Firestore
  Future<void> getUsername(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['name']; // Almacenar el nombre de usuario
        });
      }
    } catch (e) {
      print('Error getting username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Botón para activar/desactivar el filtro
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _toggleOnlineFilter,
              child: Text(
                  _showOnlyOnline ? 'Mostrar Solo Online' : 'Mostrar Todos'),
            ),
          ),
          // Lista de cards
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCardsData.length,
              itemBuilder: (context, index) {
                final card = _filteredCardsData[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Información de la card
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card['title'],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text(card['description']),
                              SizedBox(height: 10),
                              Text("Online: ${card['online'] ? 'Yes' : 'No'}",
                                  style:
                                      TextStyle(fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                        // Botón para abrir el link
                        IconButton(
                          icon: Icon(Icons.link),
                          onPressed: () => _launchURL(card['link']),
                          tooltip: 'Abrir enlace',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
