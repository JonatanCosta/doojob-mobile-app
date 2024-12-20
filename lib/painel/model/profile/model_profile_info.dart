import 'package:do_job_app/likes/like_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'media_gallery.dart';
import 'package:go_router/go_router.dart';

class ModelProfileInfo extends StatefulWidget {
  final Map<String, dynamic> girlData;
  final bool canEdit;

  const ModelProfileInfo({
    Key? key,
    required this.girlData,
    required this.canEdit,
  }) : super(key: key);

  @override
  _ModelProfileInfoState createState() => _ModelProfileInfoState();
}

class _ModelProfileInfoState extends State<ModelProfileInfo> {
  late Map<String, dynamic> girlData;
  late bool canEdit;

  @override
  void initState() {
    super.initState();
    girlData = widget.girlData;
    canEdit = widget.canEdit;
  }
  
  @override
  Widget build(BuildContext context) {
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
                      final serviceName = service['name']; // Nome do serviço
                      final serviceStatus = service['status']; // Status do serviço
                      return _buildChip(serviceName, serviceStatus);
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
                      _buildChip(
                        'Pagamento',
                        model['payments']
                            .map((payment) => payment['name'])
                            .join(', '),
                      ),

                      _buildChip(
                        'Locais',
                        model['locals']
                            .map((payment) => payment['name'])
                            .join(', '),
                      ),

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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )
                    ),
                    onPressed: () {
                      //_openWhatsApp(model['telephone']); // Abre o WhatsApp
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Descrição em itálico com fonte menor
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding nas bordas
            child: Center(
              child: Text(
                '${girlData['description']}',
                style: TextStyle(
                  fontSize: 16, // Fonte menor
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center, // Centraliza o texto
              ),
            ),
          ),
          SizedBox(height: 10),

          // Nome com fonte de 1.25rem e peso 600
          Text(
            '${girlData['name']}',
            style: TextStyle(
              fontSize: 20, // 1.25rem em Flutter é aproximadamente 20px
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),

          // Exibição mais bonita para o total de mídias
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   // Espaçamento entre as seções
                  // Seção de mídias
                  Column(
                    children: [
                      Icon(
                        Icons.photo_library, // Ícone de mídia
                        size: 24,
                        color: Colors.black,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${girlData['medias'].length} mídias', // Exibe o total de mídias
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center, // Centraliza o texto abaixo do ícone
                      ),
                    ],
                  ),
                  SizedBox(width: 40),
                  // Seção de preços
                  Column(
                    children: [
                      Icon(
                        FontAwesomeIcons.dollarSign, // Ícone de dinheiro do FontAwesome
                        size: 24,
                        color: Colors.black,
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          // Exibe o popup com o detalhamento de preços
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Detalhamento de Preços'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: girlData['prices']
                                      .map<Widget>((price) {
                                        return price['enabled'] == 1
                                            ? ListTile(
                                                title: Text('${price['description']}'),
                                                subtitle: Text(
                                                  'R\$ ${price['price'].toStringAsFixed(2)}',
                                                ),
                                              )
                                            : Container();
                                      })
                                      .toList(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Fecha o popup
                                    },
                                    child: Text('Fechar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          'R\$ ${girlData['prices'].firstWhere((price) => price['enabled'] == 1, orElse: () => {'price': 0})['price'].toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center, // Centraliza o texto abaixo do ícone
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openWhatsAppModel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(67, 160, 71, 1),
                      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                    label: Text(
                      'Ver Telefone',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10), // Espaço entre os botões
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDetailsModal(girlData),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900], // Fundo cinza 400
                      padding: EdgeInsets.symmetric(vertical: 19, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(Icons.info_outline, color: Colors.white), // Ícone de detalhes
                    label: Text(
                      'Detalhes',
                      style: TextStyle(
                        color: Colors.white, // Texto branco para contraste
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Galeria de Imagens e Vídeos
          MediaGallery(
            medias: girlData['medias'],
            canEdit: canEdit,
          ),

          SizedBox(height: 20),
          
          
          // Botão de "Editar Preferências"
          if (canEdit)
            const SizedBox(height: 20),
          if (canEdit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('/preferences'); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  icon: const Icon(Icons.settings, color: Colors.white),
                  label: const Text(
                    'Editar Preferências',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Função para abrir o WhatsApp com o telefone da modelo
  void _openWhatsAppModel() async {
    final phoneNumber = girlData['telephone'];
    final whatsappUrl =
        "https://wa.me/55$phoneNumber?text=Olá%20vim%20do%20aplicativo%20DooJob%20e%20quero%20mais%20informações%20sobre%20você.";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'Não foi possível abrir o WhatsApp';
    }
  }

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
}