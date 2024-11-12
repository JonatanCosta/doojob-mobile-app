import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:do_job_app/feed/services/whatsapp_service.dart';

class ProfileService {
  final WhatsAppService _whatsAppService = WhatsAppService();

  void showDetailsModal(BuildContext context, dynamic model) {
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
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    buildChip('Idade', '${model['age']} anos'),
                    buildChip('Altura', '${model['height']} cm'),
                    buildChip('Peso', '${model['weight']} kg'),
                    buildChip('Cabelo', model['hair']),
                    buildChip('Olhos', model['eyes']),
                    buildChip('Cintura', '${model['waist']} cm'),
                    buildChip('Quadril', '${model['hip']} cm'),
                    buildChip('Pés', '${model['feet']}'),
                  ],
                ),
                SizedBox(height: 16),
                Text('O que eu faço:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: model['services'].map<Widget>((service) {
                    final serviceName = service['name'];
                    final serviceStatus = service['status'];
                    return buildChip(serviceName, serviceStatus);
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Atendimento:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    buildChip('Pagamento', model['payments']
                        .map((paymentList) => paymentList.first)
                        .join(', ')),
                    buildChip('Locais', model['locals']
                        .map((localList) => localList.first)
                        .join(', ')),
                    buildChip('Cidade', model['cities']
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
                    _whatsAppService.openWhatsApp(model['telephone']);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Função auxiliar para construir chips
  Widget buildChip(String label, String value) {
    return Chip(
      label: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.black.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide.none,
      ),
    );
  }
}