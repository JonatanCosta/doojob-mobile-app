import 'package:do_job_app/likes/likes_page.dart';
import 'package:do_job_app/login/login_page.dart';
import 'package:flutter/material.dart';
import 'feed/feed_page.dart';
import 'login/login_page.dart';

void main() {
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
      initialRoute: '/feed', // Define a rota inicial
      routes: {
        '/feed': (context) => const HomeScreen(selectedIndex: 0), // Rota para o feed
        '/likes': (context) => const HomeScreen(selectedIndex: 1), // Rota para a página de likes
        '/login': (context) => const HomeScreen(selectedIndex: 2), // Rota para a página de login
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
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  static final List<Widget> _widgetOptions = <Widget>[
    FeedPage(),
    const LikesPage(),
    LoginPage()
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // Inicia com a página definida pela rota
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
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
                    Scaffold.of(context).openDrawer(); // Abre o Drawer com o contexto correto
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

// Exemplo de uma página desconhecida
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