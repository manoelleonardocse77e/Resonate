import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/landing_page.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ihotewhpojbzaljyzuaf.supabase.co', // Substitua pela URL do seu projeto
    anonKey: 'sb_publishable_LQGebe830qOQtEEUfMYylQ_jfQi0Jsl'
  );


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App',
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(), // ← sua tela aqui
    );
  }
}