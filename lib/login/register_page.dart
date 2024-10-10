import 'package:flutter/material.dart';
import 'package:do_job_app/login/login_service.dart';
import 'package:do_job_app/login/register_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Verifica o status de login ao iniciar a página

    // Adiciona um listener para exibir o popup quando o campo de telefone perde o foco
    _phoneFocusNode.addListener(() {
      if (_phoneFocusNode.hasFocus && !_popupShown) {
        _showPhonePopup();
      }
    });
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose(); // Remove o FocusNode ao finalizar a página
    super.dispose();
  }

  // Função que exibe o popup
  void _showPhonePopup() {
    setState(() {
      _popupShown = true; // Marca que o popup já foi exibido
    });
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Privacidade do Telefone'),
          content: const Text(
            'Fique tranquilo! Não enviaremos nenhuma mensagem para o número informado.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkLoginStatus() async {
    final token = await loginService.getBearerToken(); // Verifica se o token existe

    if (token != null) {
      // Se estiver logado, redireciona para o feed
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/feed');
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false; // Indicador de loading
  bool _popupShown = false;

  // Instância do LoginService
  final LoginService loginService = LoginService();
  final RegisterService registerService = RegisterService();

  Future<void> _handleRegister() async {
    final name = _nameController.text;
    final telephone = phoneMaskFormatter.getUnmaskedText();
    final password = _passwordController.text;
    //final confirm_password = _confirmPasswordController.text;

    setState(() {
      _isLoading = true;
    });

    // Utiliza o serviço de login para autenticar o usuário
    final success = await registerService.register(name, telephone, password);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Login bem-sucedido, redireciona para a página principal
      Navigator.pushReplacementNamed(context, '/feed');
    } else {
      // Exibe uma mensagem de erro em caso de falha no login
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Falha no login. Verifique suas credenciais.')),
      // );
      _showTopErrorMessage(context, 'Falha no cadastro verifique seus dados.');
    }
  }

  // Defina a máscara de telefone brasileiro
  var phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) # ####-####', 
    filter: { "#": RegExp(r'[0-9]') },
  );
  
  String? _passwordError;

  // Função para verificar se as senhas coincidem
  void _validatePasswords() {
    setState(() {
      if (_passwordController.text != _confirmPasswordController.text) {
        _passwordError = 'As senhas não coincidem';
      } else {
        _passwordError = null;
      }
    });
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
            Image.network(
              'https://doojobbucket.s3.sa-east-1.amazonaws.com/logos/logo-fundo-branco.png', // Mantenha o caminho da sua logo aqui
              height: 150,
            ),
            const Text(
              'Suas informações estão seguras! Todas as informações fornecidas são criptografadas e não serão compartilhadas.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF212121), // Cor para um texto sutil
              ),
              textAlign: TextAlign.center, // Centraliza o texto
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome ou Apelido',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Campo de Email com bordas arredondadas
            TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
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
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirme a senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                errorText: _passwordError
              ),
              obscureText: true,
              onChanged: (value) => _validatePasswords()
            ),
            const SizedBox(height: 20),
            // Botão "Entrar" ocupando 100% da tela
            _isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity, // Ocupa 100% da largura
                    child: ElevatedButton(
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Borda arredondada
                        ),
                      ),
                      child: const Text(
                        'Cadastrar',
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
              'Já possui cadastro? Clique abaixo!',
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
                  Navigator.pushNamed(context, '/login');
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF212121), // Fundo preto
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Borda arredondada
                  ),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(
                    color: Colors.white, // Texto branco
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopErrorMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60.0, // Posição no topo
        left: 20.0,
        right: 20.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
    );

    // Insere o overlay na tela
    overlay?.insert(overlayEntry);

    // Remove o overlay após 3 segundos
    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }
}