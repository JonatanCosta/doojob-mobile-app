import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:do_job_app/login/login_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class LikesPage extends StatefulWidget {
  const LikesPage({Key? key}) : super(key: key);

  @override
  _LikesPageState createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  static String baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://divinas.local:8000');

  List<dynamic> likedModels = [];

  @override
  void initState() {
    super.initState();
    fetchLikedModels();
  }

  Future<void> fetchLikedModels() async {
    final String? token = await LoginService().getBearerToken();

    if (token != null) {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/likes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          likedModels = data['likes'];
        });
      } else {
        print('Erro ao buscar os likes');
      }
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  // Função para abrir a galeria fullscreen
  Future<void> _openGallery(List<dynamic> mediaList, int index) async {
    _preloadImages(context, mediaList);  // Pré-carrega as imagens antes de abrir a galeria

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryScreen(mediaList: mediaList, initialIndex: index),
      ),
    );
  }

  // Função para pré-carregar as mídias
  Future<void> _preloadImages(BuildContext context, List<dynamic> mediaList) async {
    for (var media in mediaList) {
      precacheImage(NetworkImage(media['url']), context);
    }
  }

  Future<void> removeLike(int modelId, int index) async {
    final String? token = await LoginService().getBearerToken();
    if (token != null) {
      final response = await _sendDeleteRequest(modelId, token);

      if (response.statusCode == 200) {
        setState(() {
          likedModels.removeAt(index);  // Remove o item da lista
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Like removido com sucesso')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao remover o like')));
      }
    }
  }

  String _generateWhatsAppUrl(String phoneNumber) {
    final message = Uri.encodeComponent("Olá, vim do aplicativo DooJob e quero mais informações sobre você.");
    return "https://wa.me/$phoneNumber?text=$message";
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final url = _generateWhatsAppUrl(phoneNumber);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o WhatsApp';
    }
  }

  // Envia requisição DELETE para remover like
  Future<http.Response> _sendDeleteRequest(int modelId, String? token) {
    return http.delete(
      Uri.parse('$baseUrl/v1/like/$modelId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFFF5252),
    body: likedModels.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Column(
              children: [
                // Caixa de texto explicativa
                Container(
                  width: double.infinity, // Faz a caixa ocupar 100% da largura da tela
                  margin: const EdgeInsets.only(top: 75.0, left: 0, right: 0, bottom: 10.0), // Adiciona margem no topo e laterais
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // Fundo branco
                    borderRadius: BorderRadius.circular(0.0), // Bordas arredondadas
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2), // Sombra suave
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // Posição da sombra
                      ),
                    ],
                  ),
                  child: Text(
                    'Aqui você pode ver todas as modelos que você curtiu.',
                    style: TextStyle(fontSize: 14.0, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: likedModels.length,
                    itemBuilder: (context, index) {
                      final girl = likedModels[index]['girl'];
                      final mediaUrl = girl['medias'][0]['url'];
                      final mediaList = girl['medias']; // Lista de mídias

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                              child: Stack(
                                children: [
                                  Image.network(
                                    mediaUrl,
                                    height: 200,
                                    width: double.infinity, // Faz a imagem ocupar 100% da largura
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: IconButton(
                                      icon: Icon(Icons.zoom_in, color: Colors.white, size: 30),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => GalleryScreen(
                                              mediaList: mediaList,
                                              initialIndex: 0, // Abre a galeria na primeira imagem
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    girl['name'],
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    girl['cities'][0][0], // Exibe a primeira cidade
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  // Botões de like, WhatsApp e excluir
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          // Lógica para "descurtir"
                                          removeLike(likedModels[index]['girl']['id'], index);
                                        },
                                      ),
                                      IconButton(
                                        icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                                        onPressed: () {
                                          _openWhatsApp(girl['telephone']);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          // Lógica para remover o like
                                          removeLike(likedModels[index]['girl']['id'], index);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
  );
}
}

// Tela de galeria fullscreen
class GalleryScreen extends StatelessWidget {
  final List<dynamic> mediaList;
  final int initialIndex;

  const GalleryScreen({Key? key, required this.mediaList, required this.initialIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);  // Fecha a galeria
          },
        ),
      ),
      body: PhotoViewGallery.builder(
        itemCount: mediaList.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(mediaList[index]['url']),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}