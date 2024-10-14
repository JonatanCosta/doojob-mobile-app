import 'package:do_job_app/likes/likes_page.dart';
import 'package:do_job_app/login/login_page.dart';
import 'package:do_job_app/login/model/login_page_model.dart';
import 'package:do_job_app/login/register_page.dart';
import 'package:do_job_app/painel/model/painel_page_model.dart';
import 'package:flutter/material.dart';
import 'feed/feed_page.dart';
import 'login/login_service.dart';
import 'package:do_job_app/geolocation/location.dart';
import 'login/model/register_page_model.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DooJob - Encontre a mais perto de você',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 202, 128, 54)),
        useMaterial3: true,
      ),
      initialRoute: '/feed',
      routes: {
        '/feed': (context) => const HomeScreen(selectedIndex: 0),
        '/likes': (context) => const HomeScreen(selectedIndex: 1),
        '/login': (context) => const HomeScreen(selectedIndex: 2),
        '/register': (context) => const HomeScreen(selectedIndex: 3),
        '/register_model': (context) => const HomeScreen(selectedIndex: 4),
        '/painel': (context) => const HomeScreen(selectedIndex: 5),
        '/login_model': (context) => const HomeScreen(selectedIndex: 6),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => UnknownPage());
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final int selectedIndex;

  const HomeScreen({super.key, required this.selectedIndex});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  final LoginService loginService = LoginService(); // Instância de LoginService
  bool isLoggedIn = false;
  bool isLoggedModel = false;
  bool _showCity = false;
  String? _userCity = 'Porto Alegre';

  static final List<Widget> _widgetOptions = <Widget>[
    FeedPage(),
    const LikesPage(),
    LoginPage(),
    RegisterPage(),
    RegisterPageModel(),
    PainelPageModel(),
    LoginPageModel()
  ];

  

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _checkLoginStatus();

    LocationService locationService = LocationService();
    locationService.getSavedCity().then((city) {
      if (mounted) {
        setState(() {
          if (city != null && city.isNotEmpty) {
            _userCity = city;
            _showCity = true;
          } else {
            _showCity = false; // Não exibe o texto se a cidade não for encontrada
          }
        });

      // Exibe o texto por 3 segundos, e depois inicia o fade out suave
      if (_showCity) {
        Future.delayed(Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _showCity = false;
            });
          }
        });
      }
    }
    });
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await loginService.isLogged();
    bool loggedModel = await loginService.isLoggedModel();
    setState(() {
      isLoggedIn = loggedIn;
      isLoggedModel = loggedModel;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFFF5252), // Cor de fundo #ff5252
              ),
              child: Center(
                child: Image.network(
                  'https://doojobbucket.s3.sa-east-1.amazonaws.com/logos/logo-branca-fundo-transparente.png', // Substitui o texto pela logo
                  fit: BoxFit.contain,
                  height: 70, // Ajuste o tamanho da logo conforme necessário
                ),
              ),
            ),
            if (isLoggedModel)
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Painel da Modelo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/painel');
              },
            ),
            if (!isLoggedModel)
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Feed'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/feed');
              },
            ),
            if (!isLoggedModel)
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Likes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/likes');
              },
            ),
            if (!isLoggedIn) // Exibe o botão de Login apenas se o usuário NÃO estiver logado
            ExpansionTile(
              leading: Icon(Icons.group),
              title: Text('Cadastrar-se Grátis'),
              children: <Widget>[
                ListTile(
                  title: Text('Quero ser Cliente'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/register');
                  },
                ),
                ListTile(
                  title: Text('Quero ser Acompanhante'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/register_model');
                  },
                ),
              ],
            ),
            if (!isLoggedIn)
            ExpansionTile(
              leading: Icon(Icons.login),
              title: Text('Login'),
              children: <Widget>[
                ListTile(
                  title: Text('Login como Cliente'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                ),
                ListTile(
                  title: Text('Login como Acompanhante'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login_model');
                  },
                ),
              ],
            ),
            if (isLoggedIn)
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Sair'),
                onTap: () async {
                  await loginService.logout();
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/feed');
                },
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex), // Exibe a página correspondente
          Positioned(
            top: 15,
            left: 20,
            child: Builder(
              builder: (context) {
                return FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Icon(Icons.menu),
                );
              },
            ),
          ),
          if (_selectedIndex == 1)
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Image.network(
                'https://doojobbucket.s3.sa-east-1.amazonaws.com/logos/logo-branca-fundo-transparente.png',
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (_selectedIndex == 0) // Exibe o botão de localização apenas na rota de Feed
          Positioned(
            top: 15,
            left: 85, // Ajuste a posição horizontal
            child: Row(
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Sua cidade'),
                          content: RichText(
                            text: TextSpan(
                              text: 'Você está em ',
                              style: const TextStyle(
                                color: Colors.black, // Cor do texto padrão
                                fontSize: 16, // Tamanho do texto
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: _userCity, // A cidade em negrito
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, // Negrito para o texto da cidade
                                    color: Colors.black, // Cor preta para o texto da cidade
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            // Botão para alterar a cidade
                            SizedBox(
                              width: double.infinity, // Ocupar toda a largura da tela
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5252), // Cor de fundo (#ff5252)
                                  foregroundColor: Colors.white, // Cor do texto (branco)
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Fecha o popup
                                  // Aqui você pode adicionar a lógica para alterar a cidade
                                  LocationService locationService = LocationService();
                                  locationService.showCitySelectionPopup(context);
                                },
                                child: const Text(
                                  'Alterar Cidade',
                                  style: TextStyle(fontSize: 20), // Ajuste o tamanho do texto conforme necessário
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.filter_alt,
                    color: Colors.black
                  ),
                ),
                // Animação para exibir e ocultar o texto
                AnimatedOpacity(
                  opacity: _showCity ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000), // Tempo de fade out
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      _userCity!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Página de erro desconhecido
class UnknownPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página Desconhecida')),
      body: const Center(
        child: Text('404 - Página não encontrada'),
      ),
    );
  }
}