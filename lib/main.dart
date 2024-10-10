import 'package:do_job_app/likes/likes_page.dart';
import 'package:do_job_app/login/login_page.dart';
import 'package:do_job_app/login/register_page.dart';
import 'package:flutter/material.dart';
import 'feed/feed_page.dart';
import 'login/login_service.dart'; // Adicionei o LoginService para verificar o login

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoJob',
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

  static final List<Widget> _widgetOptions = <Widget>[
    FeedPage(),
    const LikesPage(),
    LoginPage(),
    RegisterPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await loginService.isLogged();
    setState(() {
      isLoggedIn = loggedIn;
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
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Feed'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/feed');
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Likes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/likes');
              },
            ),
            if (!isLoggedIn) // Exibe o botão de Login apenas se o usuário NÃO estiver logado
              ListTile(
                leading: Icon(Icons.login),
                title: Text('Login'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex), // Exibe a página correspondente
          Positioned(
            top: 40,
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