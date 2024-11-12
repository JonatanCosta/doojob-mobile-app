import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:do_job_app/feed/api_service.dart';
import 'package:do_job_app/likes/like_service.dart'; 
import 'package:do_job_app/geolocation/location.dart'; 
import 'package:go_router/go_router.dart'; 
import 'package:do_job_app/feed/services/age_confirmation_service.dart';
import 'package:do_job_app/feed/services/whatsapp_service.dart';
import 'package:do_job_app/feed/services/profile_service.dart';


class FeedPage extends StatefulWidget {
  final VoidCallback onCityChanged; // Adiciona o callback

  FeedPage({Key? key, required this.onCityChanged}) : super(key: key);

  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
  final ApiService apiService = ApiService();
  final WhatsAppService whatsAppService = WhatsAppService();
  final ProfileService profileService = ProfileService();

  List<dynamic> _models = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<bool> _liked = [];
  bool isLoggedIn = false; // Simulação de estado de login. Altere conforme sua lógica de autenticação.

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AgeConfirmationService(context).checkAgeConfirmation();
      fetchData();
    });
  }

  Future<void> fetchData() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await apiService.fetchGirls(currentPage);
      final List<dynamic> newModels = data['data'];

      setState(() {
        _models.addAll(newModels);
        _liked.addAll(List<bool>.filled(newModels.length, false)); // Atualiza os likes
        currentPage++;
        hasMore = data['meta']['current_page'] < data['meta']['last_page'];
      });
    } catch (error) {
      print('Erro ao buscar as modelos: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchFeed() async {
    print('Entrou aqui!');
    
    // Limpe o estado dos dados
    setState(() {
      _models.clear();
      _liked.clear();
      currentPage = 1;
      hasMore = true;
    });

    // Busque novos dados
    await fetchData();
  }

  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _models.isEmpty && !isLoading
          ? _buildNoModelsFound() // Exibe a mensagem personalizada quando não há modelos
          : PageView.builder(
              key: ValueKey(_models.length), // Use ValueKey para forçar reconstrução
              scrollDirection: Axis.vertical, // Troca para scroll vertical
              itemCount: _models.length + (hasMore ? 1 : 0), // Adiciona 1 para o loader
              onPageChanged: (index) {
                if (index == _models.length - 1 && hasMore) {
                  fetchData(); // Carrega mais dados quando chega ao final da lista
                }

                setState(() {
                  _currentImageIndex = 0; // Reinicia o contador de imagens
                });
              },
              itemBuilder: (context, index) {
                if (index == _models.length) {
                  return _buildLoader(); // Exibe o loader no final
                }

                final model = _models[index];
                return _buildModelCard(model, index);
              },
            ),
    );
  }

  Widget _buildModelCard(dynamic model, int index) {
    PageController _photoController = PageController();

    // Pré-carregar todas as imagens da modelo
    for (var media in model['medias']) {
      precacheImage(NetworkImage(media['url']), context);
      //precacheImage(CachedNetworkImageProvider(media['url']), context);
    }

    return Container(
      height: MediaQuery.of(context).size.height, // Define a altura como a altura da tela
      // Resetar o índice atual das imagens ao mudar de modelo
      child: Stack(
        children: [
          Positioned.fill(
          child: PageView.builder(
            controller: _photoController,
            itemCount: model['medias'].length + 1, // Adiciona 1 para o card extra
            onPageChanged: (int pageIndex) {
              setState(() {
                _currentImageIndex = pageIndex;
              });
            },
            itemBuilder: (context, photoIndex) {
              if (photoIndex < model['medias'].length) {
                // Exibe as imagens normais
                return Stack(
                  children: [
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
                      ),
                    ),
                    Image.network(
                      model['medias'][photoIndex]['url'],
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Card de apresentação no final
                String? coverImage = model['cover_img'];
                String? profileImage = model['profile_img'];

                if (coverImage == null || profileImage == null) {
                  coverImage = 'https://doojobbucket.s3.sa-east-1.amazonaws.com/logos/0d64989794b1a4c9d89bff571d3d5842.jpg';
                  profileImage = 'https://doojobbucket.s3.sa-east-1.amazonaws.com/logos/0d64989794b1a4c9d89bff571d3d5842.jpg';
                }

                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(coverImage), // Usa a URL de cover_img
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.7), // Define opacidade
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(profileImage), // Imagem do perfil centralizada
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.go('/p/${model['id']}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5252), // Cor do botão
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        child: const Text(
                          'Visitar Perfil',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
          // Contador de imagens no canto superior direito
          Positioned(
            top: 15,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // Fundo preto com opacidade
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${model['medias'].length + 1}', // Contador de imagens
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          // Detalhes da modelo e botões
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${model['name']}, ${model['age']} anos',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    // Botão de Detalhes ao lado da idade
                    ElevatedButton(
                      onPressed: () {
                        profileService.showDetailsModal(context, model); // Abre o modal de detalhes
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.7),
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Detalhes', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  model['cities']
                    .map((cityList) => cityList.first) // Pega o primeiro item de cada sublista
                    .join(', '), // Junta os elementos com vírgulas // Achata a lista corretamente
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Pílula com os botões de Like, WhatsApp e divisor
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white, // Fundo branco
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botão de Like
                        IconButton(
                          icon: Icon(
                            model['is_liked'] ? Icons.favorite : Icons.favorite_border,
                            color: model['is_liked'] ? Colors.red : Colors.black,
                            size: 30,
                          ),
                          onPressed: () {
                            LikeService(context, isLoggedIn: isLoggedIn).onLikePressed(index, model['is_liked'], model['id'], (isLiked) {
                              setState(() {
                                model['is_liked'] = isLiked;  // Chama setState para atualizar a UI
                              });
                              print("Model is liked: ${model['is_liked']}");
                            });
                          },
                        ),
                        // Divisor vertical entre os botões
                        Container(
                          height: 28,  // Alinhado à altura dos ícones
                          width: 1,  // Espessura do divisor
                          color: const Color.fromARGB(255, 60, 60, 60),  // Cor do divisor
                          margin: EdgeInsets.symmetric(horizontal: 15),  // Espaçamento
                        ),
                        // Botão de WhatsApp
                        IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.green,
                            size: 30,
                          ),
                          onPressed: () {
                            whatsAppService.openWhatsApp(model['telephone']);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)), // Cor personalizada do loader
      ));
    } else {
      return SizedBox.shrink();
    }
  }

  // Função para exibir a mensagem quando não há modelos encontrados
  Widget _buildNoModelsFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '😔',
              style: TextStyle(fontSize: 50), // Ícone triste grande
            ),
            SizedBox(height: 20),
            Text(
              'Nenhuma modelo foi encontrada na sua região.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Clique abaixo para mudar a cidade.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                LocationService locationService = LocationService();
                await locationService.showCitySelectionPopup(context);
                widget.onCityChanged();

                // Atualiza a lista de modelos após a mudança de cidade
                setState(() {
                  _models.clear();
                  _liked.clear();
                  currentPage = 1;
                  hasMore = true;
                  fetchData();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF5252), // Cor do botão
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Tamanho do botão
              ),
              child: Text(
                'Mudar Cidade',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}