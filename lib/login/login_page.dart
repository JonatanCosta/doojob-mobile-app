import 'package:flutter/material.dart';
import 'package:do_job_app/login/login_service.dart'; // Importe o serviço de login

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      Navigator.pushReplacementNamed(context, '/feed');
    }
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Indicador de loading

  // Instância do LoginService
  final LoginService loginService = LoginService();

  Future<void> _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    // Utiliza o serviço de login para autenticar o usuário
    final success = await loginService.login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Login bem-sucedido, redireciona para a página principal
      Navigator.pushReplacementNamed(context, '/feed');
    } else {
      // Exibe uma mensagem de erro em caso de falha no login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no login. Verifique suas credenciais.')),
      );
    }
  }

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
            Image.asset(
              'assets/logo.png', // Mantenha o caminho da sua logo aqui
              height: 250,
            ),
            const SizedBox(height: 25),
            const Text(
              'Bem-vindo!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Campo de Email com bordas arredondadas
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
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
                        backgroundColor: Colors.blue,
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
            const SizedBox(height: 20),
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
                  Navigator.pushNamed(context, '/register');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black, // Fundo preto
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Borda arredondada
                  ),
                ),
                child: const Text(
                  'Cadastrar-se',
                  style: TextStyle(
                    color: Colors.white, // Texto branco
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}