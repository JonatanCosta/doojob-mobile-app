import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'media_gallery.dart';

class ModelProfileInfo extends StatelessWidget {
  final Map<String, dynamic> girlData;
  final bool canEdit;

  const ModelProfileInfo({
    Key? key,
    required this.girlData,
    required this.canEdit,
  }) : super(key: key);

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
          Text(
            '${girlData['description']}',
            style: TextStyle(
              fontSize: 16, // Fonte menor
              fontStyle: FontStyle.italic,
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
          SizedBox(height: 10),

          // Exibição mais bonita para o total de mídias
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${girlData['medias'].length} mídias', // Exibe o total de mídias
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.photo_library_outlined, // Ícone outline
                size: 24,
                color: Colors.black, // Cor preta
              ),
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
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
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
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
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
            SizedBox(height: 20),
          if (canEdit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    //Navigator.pushNamed(context, '/painel/preferences');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  icon: Icon(Icons.settings, color: Colors.white),
                  label: Text(
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