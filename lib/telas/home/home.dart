import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:prova_p2/auth/autenticacao.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.displayName ?? 'Meu Painel'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              authService.signOut();
            },
          ),
        ],
      ),
      body: const Center(
        child: SizedBox.shrink(),
      ),
    );
  }
}
