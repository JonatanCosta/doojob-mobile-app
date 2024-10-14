import 'package:flutter/material.dart';
import 'painel_page_service.dart';
import 'step_form.dart';
import 'package:url_launcher/url_launcher.dart';

class PainelPageModel extends StatefulWidget {
  @override
  _PainelPageModel createState() => _PainelPageModel();
}

class _PainelPageModel extends State<PainelPageModel> {
  Map<String, dynamic>? girlData;
  Map<String, dynamic>? loggedUser;
  bool isLoading = true;
  final PainelPageService painelService = PainelPageService();
  List<String> selectedLocals = [];

  @override
  void initState() {
    super.initState();
    _loadModelData();
    _loadUserData();
  }

  Future<void> _loadModelData() async {
    final fetchGirl = await painelService.fetchGirl();
    setState(() {
      girlData = fetchGirl;
    });
  }

  Future<void> _loadUserData() async {
    final fetchUser = await painelService.fetchUser();
    setState(() {
      loggedUser = fetchUser;
      isLoading = false;
    });
  }

  void _showLocalsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Preencher Locais"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text("Móteis"),
                    value: selectedLocals.contains("Motéis"),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedLocals.add("Motéis");
                        } else {
                          selectedLocals.remove("Motéis");
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Hotéis"),
                    value: selectedLocals.contains("Hotéis"),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedLocals.add("Hotéis");
                        } else {
                          selectedLocals.remove("Hotéis");
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Residência"),
                    value: selectedLocals.contains("Residência"),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedLocals.add("Residência");
                        } else {
                          selectedLocals.remove("Residência");
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Virtual"),
                    value: selectedLocals.contains("Virtual"),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedLocals.add("Virtual");
                        } else {
                          selectedLocals.remove("Virtual");
                        }
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Envia os locais selecionados
                //await painelService.updateLocals(selectedLocals);
                Navigator.of(context).pop();
                // Atualiza a tela após o envio
                _loadModelData();
              },
              child: Text("Salvar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF5252), // Cor do botão
              ),
            ),
          ],
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  if (isLoading) {
    return Center(child: CircularProgressIndicator());
  }

  if (girlData == null) {
    return StepForm(); // Exibe o formulário step-by-step se não houver dados
  }

  return Scaffold(
    backgroundColor: Colors.white,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo no topo da página
        Container(
          padding: EdgeInsets.only(top: 10), // Ajuste o padding conforme necessário
          child: Center(
            child: Image.network(
              'https://doojobbucket.s3.sa-east-1.amazonaws.com/logos/logo-fundo-branco.png',
              height: 80, // Ajuste a altura conforme necessário
            ),
          ),
        ),
        SizedBox(height: 20), // Espaço entre a logo e os dados da girl

        // Exibição de dados da girlData
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Centraliza horizontalmente
            children: [
              Text(
                'Nome: ${girlData!['name']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Email: ${girlData!['email']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Telefone: ${girlData!['telephone']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              // Botão de suporte com link para WhatsApp
              ElevatedButton.icon(
                onPressed: _openWhatsAppSupport, // Função para abrir o WhatsApp
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF25D366), // Cor verde do WhatsApp
                  minimumSize: Size(200, 50), // Tamanho maior do botão
                ),
                icon: Icon(Icons.support, color: Colors.white),
                label: Text(
                  'Suporte via WhatsApp',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 30), // Espaço entre os dados e o card

        // Card centralizado com o restante do conteúdo
        Expanded(
          child: Center(
            child: Card(
              elevation: 2,
              color: Colors.yellow[100], // Fundo amarelo sutil
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Mantém o tamanho do card ajustado ao conteúdo
                  crossAxisAlignment: CrossAxisAlignment.center, // Centraliza horizontalmente
                  children: [
                    Text(
                      "Estamos quase lá! Finalize seu cadastro.",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (girlData!['locals'] == null || girlData!['locals'].isEmpty) ...[
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: _showLocalsPopup,
                        child: Text(
                          "Preencher Locais",
                          style: TextStyle(color: Color(0xFFFF5252)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  // Função para abrir o WhatsApp de suporte
  void _openWhatsAppSupport() async {
    const whatsappUrl = "https://wa.me/555199999999?text=Olá, preciso de suporte";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'Não foi possível abrir o WhatsApp';
    }
  }
}