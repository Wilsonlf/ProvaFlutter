import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../auth/autenticacao.dart';
import '../veiculos/veiculos_lista.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  void _navegarParaVeiculos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VeiculosListaScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.displayName ?? 'Painel Principal'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.signOut();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[700],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    user?.displayName ?? 'Usuário',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Meus Veículos'),
              onTap: () {
                Navigator.pop(context);
                _navegarParaVeiculos(context);
              },
            ),
            ListTile(
              title: const Text('Registrar Abastecimento'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Histórico de Abastecimentos'),
              onTap: () {},
            ),
            const Divider(),
          ],
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _navegarParaVeiculos(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: const Text(
            'Gerenciar Veículos',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
