import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// importe suas telas
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_transacao_screen.dart';
import 'screens/categoria_screen.dart';
import 'screens/detalhes_financeiros_screen.dart';
//import 'widgets/export_util.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de Gastos',
      theme: ThemeData(
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent, // cor do FAB
          foregroundColor: Colors.white, // cor do ícone do FAB
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 240, 243, 230), // cor de fundo padrão
        appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue, // cor da AppBar
        foregroundColor: Colors.white, // cor do texto da AppBar
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          color: const Color.fromARGB(226, 250, 250, 248),
          shadowColor: const Color.fromARGB(255, 245, 244, 242),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // aqui usamos o StreamBuilder para decidir qual tela mostrar
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // usuário logado → vai para HomeScreen
            return const HomeScreen();
          }
          // usuário não logado → vai para LoginScreen
          return const LoginScreen();
        },
      ),
      initialRoute: '/',
      routes: {
        //'/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/categorias': (context) => const CategoriasScreen(),
        '/detalhes': (context) => const DetalhesFinanceirosScreen(),
        '/addTransacao': (context) => const AddTransacaoScreen(),
      },
    );
  }
}