import 'package:flutter/material.dart';
import 'painel_page_service.dart';
import 'step_form.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model_profile_scaffold.dart';

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
      return const Center(child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)), // Cor personalizada do loader
      ));
    }

    if (girlData == null) {
      return StepForm(loggedUser: loggedUser!); // Exibe o formulário step-by-step se não houver dados
    }

    return ModelProfileScaffold(girlData: girlData!, canEdit: true,); // Reutiliza o scaffold do perfil
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