import 'package:flutter/material.dart';
import 'package:do_job_app/login/login_service.dart'; // Importe o serviço de login
import 'package:animated_text_kit/animated_text_kit.dart'; // Importe a biblioteca de animação
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPageModel extends StatefulWidget {
  @override
  _LoginPageModelState createState() => _LoginPageModelState();
}

class _LoginPageModelState extends State<LoginPageModel> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Verifica o status de login ao iniciar a página
  }

  Future<void> _checkLoginStatus() async {
    final token = await loginService.getBearerToken(); // Verifica se o token existe

    if (token != null) {
      // Se estiver logado, redireciona para o feed
      // ignore: use_build_context_synchronously
      context.go('/painel');
    }
  }

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Indicador de loading

  // Instância do LoginService
  final LoginService loginService = LoginService();

  Future<void> _handleLogin() async {
    final phone = phoneMaskFormatter.getUnmaskedText();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      // Utiliza o serviço de login para autenticar o usuário
      final response = await loginService.login(phone, password, true);

      setState(() {
        _isLoading = false;
      });

      final isModel = response['is_model'];
      
      if (isModel == 1) {
        return context.go('/painel');
      } else {
        return context.go('/feed');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Exibe uma mensagem de erro em caso de falha no login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no login. Verifique suas credenciais e tente novamente.')),
      );
    }
  }

  // Defina a máscara de telefone brasileiro
  var phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) # ####-####', 
    filter: { "#": RegExp(r'[0-9]') },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Manter o design da logo
            Image.network(
              'https://doojobbucket.s3.sa-east-1.amazonaws.com/logos/logo-fundo-branco.png', // Mantenha o caminho da sua logo aqui
              height: 150,
            ),
            const SizedBox(height: 5),
            // Adiciona a animação de máquina de escrever
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Encontre a sua do Job!',
                  textStyle: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 70),
                ),
                TypewriterAnimatedText(
                  'Modelos Verificadas!',
                  textStyle: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 70),
                ),
                TypewriterAnimatedText(
                  'Prazer garantido!',
                  textStyle: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 70),
                ),
              ],
              totalRepeatCount: 5, // A animação vai rodar uma vez
              pause: const Duration(milliseconds: 1000), // Pausa entre os textos
              displayFullTextOnTap: true, // Mostra o texto completo ao clicar
              stopPauseOnTap: true, // Pausa se clicar
            ),
            const SizedBox(height: 25),
            // Campo de Email com bordas arredondadas
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone, // Define o teclado numérico
              inputFormatters: [phoneMaskFormatter], // Aplica a máscara
              decoration: InputDecoration(
                labelText: 'Número de Telefone Celular',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Campo de Senha com bordas arredondadas
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            // Botão "Entrar" ocupando 100% da tela
            _isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity, // Ocupa 100% da largura
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Borda arredondada
                        ),
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 40),
            // Botão "Cadastrar-se" ocupando 100% da tela e com cor preta
            const Text(
              'Não possui cadastro? Clique abaixo!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, // Ocupa 100% da largura
              child: TextButton(
                onPressed: () {
                  //Navigator.pushNamed(context, '/register_model');
                  context.go('/register_model'); // Navega para a página de cadastro
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF212121), // Fundo preto
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Borda arredondada
                  ),
                ),
                child: const Text(
                  'Quero me cadastrar',
                  style: TextStyle(
                    color: Colors.white, // Texto branco
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: "Este site é protegido pelo reCAPTCHA e as "),
                  TextSpan(
                    text: "Política de Privacidade",
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch("https://policies.google.com/privacy");
                      },
                  ),
                  TextSpan(text: " e "),
                  TextSpan(
                    text: "Termos de Serviço",
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch("https://policies.google.com/terms");
                      },
                  ),
                  TextSpan(text: " do Google se aplicam."),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}