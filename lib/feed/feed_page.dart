import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:do_job_app/feed/api_service.dart'; // Importa o serviço de API
import 'package:do_job_app/likes/like_service.dart'; // Importa o serviço de likes
import 'package:shared_preferences/shared_preferences.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final ApiService apiService = ApiService();
  List<dynamic> _models = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<bool> _liked = [];
  bool isLoggedIn = false; // Simulação de estado de login. Altere conforme sua lógica de autenticação.

  @override
  void initState() {
    super.initState();
    _checkAgeConfirmation();
    fetchData();
  }

  // Verifica se o usuário já aceitou o aviso de conteúdo adulto
  Future<void> _checkAgeConfirmation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isAdult = prefs.getBool('isAdult');

    print("isAdult: $isAdult");

    // Se o usuário ainda não confirmou, exibe o popup
    if (isAdult == null || !isAdult) {
      _showAgeConfirmationPopup();
    }
  }

  // Função que exibe o popup para confirmar a idade
  void _showAgeConfirmationPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Impede que o popup seja fechado sem ação
      barrierColor: Colors.black.withOpacity(0.9), // Define o fundo com opacidade
      builder: (BuildContext context) {
        return AlertDialog(
          
          title: const Text('Aviso: Conteúdo Adulto 18+'),
          content: const Column(
            mainAxisSize: MainAxisSize.min, // Garante que a coluna ocupe apenas o espaço necessário
            crossAxisAlignment: CrossAxisAlignment.start, // Alinha os textos à esquerda
            children: [
              Text(
                'Entendo que o site DooJob apresenta conteúdo explícito destinado a adultos.',
                style: TextStyle(
                  fontSize: 18, // Tamanho maior para o primeiro texto
                  fontWeight: FontWeight.bold, // Negrito para destacar
                ),
              ),
              SizedBox(height: 15), // Espaçamento entre os dois textos
              Text(
                'A profissão de acompanhante é legalizada no Brasil e deve ser respeitada.',
                style: TextStyle(
                  fontSize: 14, // Tamanho menor para o segundo texto
                  color: Colors.grey, // Cor mais clara para o segundo texto
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity, // Faz o botão ocupar 100% da largura
              child: ElevatedButton(
                onPressed: () async {
                  // Salva a confirmação de idade e fecha o popup
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isAdult', true); // Salva que o usuário é maior de idade
                  Navigator.of(context).pop();
                },
                child: const Text('Concordo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15), // Aumenta a altura do botão
                  backgroundColor: const Color(0xFFFF5252), // Cor de fundo (#FFFF5252)
                  foregroundColor: Colors.white, // Texto branco
                  textStyle: const TextStyle(fontSize: 20),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Remove bordas arredondadas
                    )
                  ),
              ),
            ),
          ],
        );
      },
    );
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

  int _currentImageIndex = 0;

  // Função auxiliar para construir chips
  Widget _buildChip(String label, String value) {
    return Chip(
      label: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12, // Texto menor
          color: Colors.white, // Texto branco
        ),
      ),
      backgroundColor: Colors.black.withOpacity(0.7), // Preto com opacidade no fundo
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Remove bordas extras
        side: BorderSide.none, // Sem borda
      ),
    );
  }

  void _showDetailsModal(dynamic model) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Perfil:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                spacing: 8.0, // Espaçamento horizontal entre as pílulas
                runSpacing: 4.0, // Espaçamento vertical entre as linhas
                children: [
                  _buildChip('Idade', '${model['age']} anos'),
                  _buildChip('Altura', '${model['height']} cm'),
                  _buildChip('Peso', '${model['weight']} kg'),
                  _buildChip('Cabelo', model['hair']),
                  _buildChip('Olhos', model['eyes']),
                  _buildChip('Cintura', '${model['waist']} cm'),
                  _buildChip('Quadril', '${model['hip']} cm'),
                  _buildChip('Pés', '${model['feet']}'),
                ],
              ),
              SizedBox(height: 16),
              // Seção "O que eu faço"
              Text('O que eu faço:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0, // Espaçamento horizontal entre as pílulas
                runSpacing: 4.0, // Espaçamento vertical entre as linhas
                children: model['services'].map<Widget>((service) {
                  final serviceKey = service.keys.first; // A chave do serviço (ex: 'Oral')
                  final serviceValue = service.values.first; // O valor do serviço (ex: 'Sim')
                  return _buildChip(serviceKey, serviceValue);
                }).toList(),
              ),
                const SizedBox(height: 16),
                // Seção "Atendimento"
                const Text('Atendimento:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    // Chip de Pagamento
                    _buildChip('Pagamento', model['payments']
                        .map((paymentList) => paymentList.first)
                        .join(', ')),

                    // Chip de Locais
                    _buildChip('Locais', model['locals']
                        .map((localList) => localList.first)
                        .join(', ')),

                    // Chip de Cidades
                    _buildChip('Cidade', model['cities']
                        .map((cityList) => cityList.first)
                        .join(', ')),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                  label: Text('Vamos Agendar?'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: () {
                    _openWhatsApp(model['telephone']); // Abre o WhatsApp
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical, // Troca para scroll vertical
        itemCount: _models.length + (hasMore ? 1 : 0), // Adiciona 1 para o loader
        onPageChanged: (index) {
          if (index == _models.length - 1 && hasMore) {
            fetchData(); // Carrega mais dados quando chega ao final da lista
          }

          setState(() {
            _currentImageIndex = 0;  // Reinicia o contador de imagens
          });
        },
        itemBuilder: (context, index) {
          if (index == _models.length) {
            return _buildLoader();
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
  }

  return Container(
    height: MediaQuery.of(context).size.height, // Define a altura como a altura da tela
    // Resetar o índice atual das imagens ao mudar de modelo
    child: Stack(
      children: [
        // PageView para exibir as imagens
        Positioned.fill(
          child: PageView.builder(
            controller: _photoController,
            itemCount: model['medias'].length,
            onPageChanged: (int pageIndex) {
              setState(() {
                _currentImageIndex = pageIndex;
              });
            },
            itemBuilder: (context, photoIndex) {
              return Stack(
                children: [
                  Center(child: CircularProgressIndicator()), // Loader enquanto carrega a imagem
                  Image.network(
                    model['medias'][photoIndex]['url'],
                    fit: BoxFit.cover,
                    height: double.infinity, // Garante que a imagem cubra toda a área disponível
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
        // Contador de imagens no canto superior direito
        Positioned(
          top: 50,
          right: 20,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Fundo preto com opacidade
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${model['medias'].length}', // Contador de imagens
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
                      _showDetailsModal(model); // Abre o modal de detalhes
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
                        icon: FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                          size: 30,
                        ),
                        onPressed: () {
                          _openWhatsApp(model['telephone']); // Abre o WhatsApp
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
      return Center(child: CircularProgressIndicator());
    } else {
      return SizedBox.shrink();
    }
  }
}