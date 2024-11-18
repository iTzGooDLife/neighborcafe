import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:dio/dio.dart';
import 'package:http/io_client.dart';

import 'package:neighborcafe/src/settings/app_colors.dart';

class RecommendationsView extends StatefulWidget {
  const RecommendationsView({super.key});

  @override
  _RecommendationsViewState createState() => _RecommendationsViewState();
}

class _RecommendationsViewState extends State<RecommendationsView> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? loggedinUser; // Cambia a User? para permitir valores nulos
  String username = '';
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _messages.add(
        "¡Hola! Soy tu asistente virtual para darte recomendaciones sobre el café. ¡Pregúntamente lo que desees!");
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

  Future<String?> getIdToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(_controller.text);
        _isLoading = true;
      });

      String? token = await getIdToken();
      if (token == null) {
        print('Error: No se pudo obtener el token de ID');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Construir el cuerpo de la solicitud
      final requestBody = {
        'user': username,
        'query': _controller.text,
        'chat_history': _messages,
      };

      final ByteData data = await rootBundle.load('assets/certs/cert.pem');
      SecurityContext context = SecurityContext.defaultContext;
      context.setTrustedCertificatesBytes(data.buffer.asUint8List());

      HttpClient client = HttpClient(context: context);
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      final ioClient = IOClient(client);

      final response =
          await ioClient.post(Uri.parse('https://10.0.2.2:5555/chatbot'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(requestBody));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _messages.add(responseData['response']);
        });
      } else {
        print('Error: ${response.statusCode}');
      }

      setState(() {
        _isLoading = false;
      });

      _controller.clear();
    }
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
      _messages.add(
          "¡Hola! Soy tu asistente virtual para darte recomendaciones sobre el café. ¡Pregúntamente lo que desees!");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  bool isUserMessage =
                      index != 0 && index % 2 != 0; // Mensajes del usuario
                  bool isBotMessage =
                      index != 0 && index % 2 == 0; // Mensajes del bot
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: isUserMessage
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: isUserMessage
                                  ? AppColors.secondaryColor
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _messages[index],
                              style: TextStyle(
                                color: isUserMessage
                                    ? Colors.white
                                    : isBotMessage
                                        ? Colors.black
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_isLoading) // Mostrar el indicador de carga si _isLoading es true
              Center(
                child: CircularProgressIndicator(),
              ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Escribe tu mensaje',
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    child: Text('Enviar'),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: _resetChat,
                  icon: Icon(Icons.refresh),
                  color:
                      AppColors.secondaryColor, // Color del icono de reinicio
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
