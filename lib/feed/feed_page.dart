import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeedPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final List<Map<String, dynamic>> _models = [
    {
      'name': 'Alice',
      'age': '40',
      'city': 'Porto Alegre',
      'phone': '+555199999999',
      'photos': [
        'https://picsum.photos/650/300',
        'https://picsum.photos/650/350',
      ],
      'profile': {
        'Idade': '40 anos',
        'Altura': '1.60cm',
        'Peso': '65kg',
        'Pés': '36',
        'Cabelo': 'Loiro',
        'Olhos': 'Castanhos',
        'Cintura': '69cm',
        'Quadril': '115cm',
      },
      'jobs': {
        'Oral': 'Sim',
        'Beija': 'Sim',
        'Anal': 'Talvez',
        'Amigas': 'Sim',
        'Viagem': 'Talvez',
        'Dominação': 'Sim',
        'Inversão': 'Sim',
        'Atende': 'Eles, Casais',
        'Podolatria': 'Sim',
      },
      'service': {
        'Pagamento': 'Dinheiro, Cartão de Crédito, Cartão de débito, Pix',
        'Locais': 'Hotéis, Motéis, Residências, Atendimento Virtual',
        'Cidade': 'RS, Canoas, Novo Hamburgo, Porto Alegre, São Leopoldo',
      },
    },
    {
      'name': 'Alice',
      'age': '40',
      'city': 'Porto Alegre',
      'phone': '+555199999999',
      'photos': [
        'https://picsum.photos/600/300',
        'https://picsum.photos/600/350',
      ],
      'profile': {
        'Idade': '40 anos',
        'Altura': '1.60cm',
        'Peso': '65kg',
        'Pés': '36',
        'Cabelo': 'Loiro',
        'Olhos': 'Castanhos',
        'Cintura': '69cm',
        'Quadril': '115cm',
      },
      'jobs': {
        'Oral': 'Sim',
        'Beija': 'Sim',
        'Anal': 'Talvez',
        'Amigas': 'Sim',
        'Viagem': 'Talvez',
        'Dominação': 'Sim',
        'Inversão': 'Sim',
        'Atende': 'Eles, Casais',
        'Podolatria': 'Sim',
      },
      'service': {
        'Pagamento': 'Dinheiro, Cartão de Crédito, Cartão de débito, Pix',
        'Locais': 'Hotéis, Motéis, Residências, Atendimento Virtual',
        'Cidade': 'RS, Canoas, Novo Hamburgo, Porto Alegre, São Leopoldo',
      },
    },
    {
      'name': 'Alice',
      'age': '40',
      'city': 'Porto Alegre',
      'phone': '+555199999999',
      'photos': [
        'https://picsum.photos/500/300',
        'https://picsum.photos/500/350',
      ],
      'profile': {
        'Idade': '40 anos',
        'Altura': '1.60cm',
        'Peso': '65kg',
        'Pés': '36',
        'Cabelo': 'Loiro',
        'Olhos': 'Castanhos',
        'Cintura': '69cm',
        'Quadril': '115cm',
      },
      'jobs': {
        'Oral': 'Sim',
        'Beija': 'Sim',
        'Anal': 'Talvez',
        'Amigas': 'Sim',
        'Viagem': 'Talvez',
        'Dominação': 'Sim',
        'Inversão': 'Sim',
        'Atende': 'Eles, Casais',
        'Podolatria': 'Sim',
      },
      'service': {
        'Pagamento': 'Dinheiro, Cartão de Crédito, Cartão de débito, Pix',
        'Locais': 'Hotéis, Motéis, Residências, Atendimento Virtual',
        'Cidade': 'RS, Canoas, Novo Hamburgo, Porto Alegre, São Leopoldo',
      },
    }
  ];

  List<bool> _liked = [];

  @override
  void initState() {
    super.initState();
    _liked = List<bool>.filled(_models.length, false);
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

  void _showDetailsModal(Map<String, dynamic> model) {
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
                children: model['profile'].entries.map<Widget>((entry) {
                  return Chip(
                    label: Text(
                      '${entry.key}: ${entry.value}',
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
                }).toList(),
              ),
              SizedBox(height: 16),
              Text('O que eu faço:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: model['jobs'].entries.map<Widget>((entry) {
                  return Chip(
                    label: Text(
                      '${entry.key}: ${entry.value}',
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
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Atendimento:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: model['service'].entries.map<Widget>((entry) {
                  return Chip(
                    label: Text(
                      '${entry.key}: ${entry.value}',
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
                }).toList(),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                label: Text('Vamos Agendar?'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _openWhatsApp(model['phone']);
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
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _models.length,
      onPageChanged: (int newIndex) {
        // Reseta o contador de imagens ao mudar de modelo
        setState(() {
          _currentImageIndex = 0;  // Reinicia o contador de imagens
        });
      },
      itemBuilder: (context, index) {
        final model = _models[index];
        PageController _photoController = PageController();
        return Stack(
          children: [
            // PageView para exibir as imagens
            PageView.builder(
              controller: _photoController,
              itemCount: model['photos'].length,
              onPageChanged: (int pageIndex) {
                setState(() {
                  _currentImageIndex = pageIndex;
                });
              },
              itemBuilder: (context, photoIndex) {
                return Stack(
                  children: [
                    Center(
                      child: CircularProgressIndicator(), // Exibe o loader no centro enquanto a imagem carrega
                    ),
                    Image.network(
                      model['photos'][photoIndex],
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // Se a imagem for carregada, exibe a imagem
                        } else {
                          // Exibe o loader enquanto a imagem está sendo carregada
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null, // Exibe o progresso se disponível
                            ),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            // Contador de imagens no canto superior direito
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5), // Fundo preto com opacidade
                  borderRadius: BorderRadius.circular(12), // Borda arredondada
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${model['photos'].length}', // Atualiza dinamicamente o contador
                  style: TextStyle(
                    color: Colors.white, // Texto branco
                    fontSize: 12, // Tamanho menor do texto
                  ),
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
                      // Botão de Detalhes ao lado da idade, menor
                      ElevatedButton(
                        onPressed: () {
                          _showDetailsModal(model);
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
                    model['city'],
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
                      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 5), // Ajustado conforme sua alteração
                      decoration: BoxDecoration(
                        color: Colors.white, // Fundo branco
                        borderRadius: BorderRadius.circular(30), // Borda arredondada
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Botão de Like
                          IconButton(
                            icon: Icon(
                              _liked[index] ? Icons.favorite : Icons.favorite_border,
                              color: _liked[index] ? Colors.red : Colors.black,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                _liked[index] = !_liked[index];
                              });
                            },
                          ),
                          // Divisor vertical entre os botões (usando Container)
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
                              _openWhatsApp(model['phone']);
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
        );
      },
    );
  }
}