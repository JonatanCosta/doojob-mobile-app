import 'package:flutter/material.dart';
import '../painel/model/model_profile_scaffold.dart';
import '../painel/model/painel_page_service.dart'; // Supondo que você tenha um serviço para buscar os dados

class ProfilePage extends StatefulWidget {
  final String girlID;

  const ProfilePage({Key? key, required this.girlID}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? girlData;
  bool isLoading = true;

  final PainelPageService painelService = PainelPageService();

  @override
  void initState() {
    super.initState();
    _fetchGirlData(); // Busca os dados da modelo ao iniciar a página
  }

  Future<void> _fetchGirlData() async {
    final fetchGirl = await painelService.fetchProfile(widget.girlID);
    
    setState(() {
      girlData = fetchGirl;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)))),
      );
    }

    if (girlData == null) {
      return Scaffold(
        body: Center(child: Text('Modelo não encontrada')),
      );
    }

    return ModelProfileScaffold(
      girlData: girlData!,
      canEdit: false, // Desativa a edição
    );
  }
}