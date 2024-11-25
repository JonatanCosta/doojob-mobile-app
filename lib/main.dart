import 'package:do_job_app/likes/likes_page.dart';
import 'package:do_job_app/login/login_page.dart';
import 'package:do_job_app/login/model/login_page_model.dart';
import 'package:do_job_app/login/register_page.dart';
import 'package:do_job_app/painel/model/painel_page_model.dart';
import 'package:do_job_app/search/search_page.dart';
import 'package:flutter/material.dart';
import 'feed/feed_page.dart';
import 'login/login_service.dart';
import 'package:do_job_app/geolocation/location.dart';
import 'login/model/register_page_model.dart';
import 'profile/profile.dart';
import 'package:go_router/go_router.dart';
import 'painel/model/preferences_page.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // Import necessário para configurar a URL
import 'package:flutter/foundation.dart'; // Import necessário para kIsWeb
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';

void main() async {
  setUrlStrategy(PathUrlStrategy()); // Remove o # da URL
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await GRecaptchaV3.ready("6Lcv0HsqAAAAAPUO2TF-e2hjNntHnRNavuOOheF7");
    Future.delayed(Duration(milliseconds: 100), () {
      GRecaptchaV3.hideBadge();
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      routes: [
        GoRoute(
          path: '/feed',
          builder: (context, state) => const HomeScreen(selectedIndex: 0),
        ),
        GoRoute(
          path: '/likes',
          builder: (context, state) => const HomeScreen(selectedIndex: 1),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const HomeScreen(selectedIndex: 2),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const HomeScreen(selectedIndex: 3),
        ),
        GoRoute(
          path: '/register_model',
          builder: (context, state) => const HomeScreen(selectedIndex: 4),
        ),
        GoRoute(
          path: '/painel',
          builder: (context, state) => const HomeScreen(selectedIndex: 5),
        ),
        GoRoute(
          path: '/login_model',
          builder: (context, state) => const HomeScreen(selectedIndex: 6),
        ),
        GoRoute(
          path: '/p/:girlID',
          builder: (context, state) {
            final girlID = state.params['girlID']!;
            return HomeScreen(selectedIndex: 7, paramID: girlID);
          },
        ),
        GoRoute(path: '/preferences',
          builder: (context, state) => const HomeScreen(selectedIndex: 8),
        ),
        GoRoute(path: '/search',
          builder: (context, state) => const HomeScreen(selectedIndex: 9),
        ),
      ],
      redirect: (context, state) {
        if (state.subloc == '/') {
          return '/feed';  // Redireciona a rota raiz para /feed
        }
        return null;  // Sem redirecionamento se não for a rota '/'
      },
      errorBuilder: (context, state) => UnknownPage(), // Página 404
    );

    return MaterialApp.router(
      title: 'DooJob - Encontre a mais perto de você',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 202, 128, 54)),
        useMaterial3: true,
      ),
      routerConfig: _router, // Usa GoRouter para gerenciar as rotas
    );
  }
}

class HomeScreen extends StatefulWidget {
  final int selectedIndex;
  final String? paramID;

  const HomeScreen({super.key, required this.selectedIndex, this.paramID});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  final LoginService loginService = LoginService();
  bool isLoggedIn = false;
  bool isLoggedModel = false;
  bool _showCity = false;
  String? _userCity = 'Porto Alegre';
  final GlobalKey<FeedPageState> _feedPageKey = GlobalKey<FeedPageState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _checkLoginStatus();
    _fetchCity();
  }

  Future<void> _fetchCity() async {
    LocationService locationService = LocationService();
    await locationService.getSavedCity().then((city) {
      if (mounted) {
        setState(() {
          if (city != null && city.isNotEmpty) {
            _userCity = city;
            _showCity = true;
          } else {
            _showCity = false; // Não exibe o texto se a cidade não for encontrada
          }
        });

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
    //_feedPageKey.currentState?.fetchFeed();
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
    final List<Widget> _widgetOptions = <Widget>[
      FeedPage(key: _feedPageKey, onCityChanged: () => _fetchCity()),
      LikesPage(),
      LoginPage(),
      RegisterPage(),
      RegisterPageModel(),
      PainelPageModel(),
      LoginPageModel(),
      widget.paramID != null
          ? ProfilePage(girlID: widget.paramID!)
          : Center(child: Text('ID da modelo não encontrado!')),
      PreferencesPage(),
      SearchPage(),
    ];

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
                context.go('/painel');
              },
            ),
            if (isLoggedModel)
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configurações'),
              onTap: () {
                context.go('/preferences');
              },
            ),
            if (!isLoggedModel)
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Feed'),
              onTap: () {
                context.go('/feed');
              },
            ),
            if (!isLoggedModel)
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Buscar'),
              onTap: () {
                context.go('/search');
              },
            ),
            if (!isLoggedModel)
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Likes'),
              onTap: () {
                context.go('/likes');
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
                    context.go('/register');
                  },
                ),
                ListTile(
                  title: Text('Quero ser Acompanhante'),
                  onTap: () {
                    context.go('/register_model');
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
                    context.go('/login');
                  },
                ),
                ListTile(
                  title: Text('Login como Acompanhante'),
                  onTap: () {
                    context.go('/login_model');
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
                  return context.pushReplacement('/feed');
                },
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _selectedIndex == 7 ? ProfilePage(girlID: widget.paramID!) :
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
                                onPressed: () async {
                                  Navigator.of(context).pop(); // Fecha o popup
                                  LocationService locationService = LocationService();
                                  await locationService.showCitySelectionPopup(context);
                                  await _fetchCity();
                                  print('Chama o fetchFeed');
                                  await _feedPageKey.currentState?.fetchFeed();
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
                    color: Colors.black,
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