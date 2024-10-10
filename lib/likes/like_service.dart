import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:do_job_app/login/login_service.dart'; // Importe o serviço de login

class LikeService {
  final BuildContext context;
  bool isLoggedIn;
  static String baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://divinas.local:8000');

  LikeService(this.context, {required this.isLoggedIn});

  // Função para curtir (ou desfazer o like)
  Future<void> onLikePressed(int index, bool isLiked, int id, Function onSuccess) async {
    final LoginService loginService = LoginService();

    if (await loginService.isLogged()) {
      // Usuário está logado
      final String? token = await loginService.getBearerToken(); // Obtem o token Bearer
      final int modelId = id;  // Pega o ID da modelo

      // Se está curtido, envia DELETE, caso contrário, envia POST
      final response = isLiked ? 
        await _sendDeleteRequest(modelId, token) : 
        await _sendPostRequest(modelId, token);

      if (response.statusCode == 200) {
        onSuccess(isLiked ? false : true); // Alterna o estado de like com sucesso
        _showToast(isLiked ? "Like removido" : "Like adicionado");
      } else {
        _showToast("Erro ao processar sua solicitação");
      }
    } else {
      // Usuário não está logado, mostra o popup de login
      _showLoginRequiredDialog();
    }
  }

  // Envia requisição POST para curtir
  Future<http.Response> _sendPostRequest(int modelId, String? token) {
    return http.post(
      Uri.parse('$baseUrl/v1/like/$modelId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // Envia requisição DELETE para remover like
  Future<http.Response> _sendDeleteRequest(int modelId, String? token) {
    return http.delete(
      Uri.parse('$baseUrl/v1/like/$modelId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // Exibe o popup para o usuário se logar ou cadastrar
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login necessário'),
          content: const Text('Para curtir uma modelo, você precisa fazer login ou se cadastrar.'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botão de Login
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white, // Fundo branco
                      side: BorderSide(color: Color(0xFFFF5252)), // Borda azul
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFFFF5252), // Texto azul
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Fecha o diálogo
                      Navigator.pushNamed(context, '/login'); // Navega para a rota de login
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Botão de Cadastrar
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5252), // Fundo azul
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Cadastrar',
                      style: TextStyle(
                        color: Colors.white, // Texto branco
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Fecha o diálogo
                      Navigator.pushNamed(context, '/register'); // Navega para a rota de cadastro
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Função para exibir um Toast
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}