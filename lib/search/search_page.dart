import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:do_job_app/geolocation/location.dart';
import 'package:do_job_app/feed/api_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:go_router/go_router.dart';
import 'package:do_job_app/feed/services/whatsapp_service.dart';
import 'package:do_job_app/search/filter_modal.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final LocationService _locationService = LocationService();
  final ApiService apiService = ApiService();
  final WhatsAppService _whatsAppService = WhatsAppService();

  List<dynamic> _models = [];
  Map<String, dynamic> _paginationData = {
    'total':  0, // Usa 0 como padrão se o valor for nulo
    'per_page': 10,
    'current_page': 1,
    'last_page': 1,
    'from': 0,
    'to': 0,
  };
  int currentPage = 1;
  bool isLoading = false;
  List<bool> _liked = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85), // Altura fixa do AppBar
        child: Container(
          child: Center(
            child: Image.network(
              'https://doojobbucket.s3.sa-east-1.amazonaws.com/logos/logo-fundo-branco.png',
              width: 230, // Altura da logo
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white, // Fundo branco
      body: Column(
        children: [
          //const SizedBox(height: 5), // Espaçamento no topo
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botão de Localização (ícone e texto juntos)
                  TextButton.icon(
                    onPressed: () async {
                      // Ação para o botão de localização
                      await _locationService.showCitySelectionPopup(context);
                      //widget.onCityChanged();

                      fetchData();
                    },
                    icon: const FaIcon(
                      Icons.location_on,
                      color: Colors.black,
                      size: 16,
                    ),
                    label: const Text(
                      'Cidade',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // Remove padding adicional
                    ),
                  ),
                  Container(
                    height: 18, // Altura alinhada ao botão
                    width: 1, // Espessura do divisor
                    color: const Color.fromARGB(255, 60, 60, 60),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                  // Botão de Filtro (ícone e texto juntos)
                  TextButton.icon(
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true, // Faz o modal ocupar a tela inteira
                        builder: (BuildContext context) {
                          return FilterModal(); // Chama o widget do modal
                        },
                      );
                    },
                    icon: const FaIcon(
                      Icons.filter_list_alt,
                      color: Colors.black,
                      size: 16,
                    ),
                    label: const Text(
                      'Filtrar',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // Remove padding adicional
                    ),
                  ),
                ],
              ),
            ),
          ), 
          if (isLoading) ...[
            const SizedBox(height: 40),
            const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
            )),
          ],
            
          if (! isLoading && _models.isEmpty) ... [
            Text('Nenhuma modelo encontrada!')
          ]
            
          else ... [
            const SizedBox(height: 5),
            Expanded(
                  child: ListView.builder(
                    itemCount: _models.length,
                    itemBuilder: (context, index) {
                      final girl = _models[index];
                      final mediaUrl = girl['medias'][0]['url'];
                      final mediaList = girl['medias'];
                      final enabledPrice = girl['prices']?.firstWhere(
                        (price) => price['enabled'] == 1,
                        orElse: () => null,
                      );

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
                                    height: 230,
                                    width: double.infinity, // Faz a imagem ocupar 100% da largura
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white, // Fundo branco
                                        shape: BoxShape.circle, // Forma redonda
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.zoom_in, color: Colors.black, size: 30), // Ícone preto
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
                                    enabledPrice != null
                                        ? '${girl['name']} - R\$${enabledPrice['price']}'
                                        : girl['name'],
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    girl['cities'][0][0], // Exibe a primeira cidade
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  // Botões de like, WhatsApp e excluir
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                                        onPressed: () {
                                          _whatsAppService.openWhatsApp(girl['telephone']);
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.go('/p/${girl['id']}');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFF5252), // Cor de fundo do botão
                                          foregroundColor: Colors.white, // Cor do texto
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Padding interno
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0), // Bordas arredondadas
                                          ),
                                        ),
                                        child: const Text(
                                          'Visitar Perfil',
                                          style: TextStyle(fontSize: 16.0), // Tamanho do texto
                                        ),
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
                // Paginador dinâmico
                if (_paginationData['last_page'] > 0) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_paginationData['last_page'], (index) {
                        final pageIndex = index + 1; // Páginas começam em 1
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: currentPage == pageIndex
                                ? null // Desativa o botão da página atual
                                : () {
                                    setState(() {
                                      currentPage = pageIndex;
                                    });
                                    fetchData(); // Atualiza os dados com a nova página
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentPage == pageIndex
                                  ? const Color(0xFFFF5252) // Destaca a página atual
                                  : Colors.grey[300],
                              foregroundColor: currentPage == pageIndex
                                  ? Colors.white
                                  : Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                            ),
                            child: Text('$pageIndex'),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
        ],
      ]),
    );
  }

  Future<void> fetchData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final params = {
        'page': currentPage,
        'status': 'approved',
      };

      final data = await apiService.fetchSearch(params);

      if (data['data'] is List) {
        final List<dynamic> newModels = data['data'];
        setState(() {
          _models = newModels; // Substitui o conteúdo de _models com os resultados
          _liked = List<bool>.filled(newModels.length, false); // Atualiza os likes
          _paginationData = {
            'total': data['pagination']['total'],
            'per_page': data['pagination']['per_page'],
            'current_page': data['pagination']['current_page'],
            'last_page': data['pagination']['last_page'],
            'from': data['pagination']['from'],
            'to': data['pagination']['to'],
          };
        });
      } else {
        print('Erro: O campo "data" não contém uma lista válida.');
      }
    } catch (error) {
      print('Erro ao buscar as modelos: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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