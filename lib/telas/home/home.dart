import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../auth/autenticacao.dart';
import '../../logic/veiculo_logic.dart';
import '../../models/veiculo.dart';
import '../veiculos/veiculo_form.dart';
import '../abastecimentos/abastecimentos_lista.dart';
import '../abastecimentos/abastecimento_historico.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final veiculoService = context.watch<VeiculoService>();
    final user = context.watch<User?>();
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.displayName ?? 'Meus Veículos'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Veículo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VeiculoForm()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(user?.displayName ?? 'Usuário',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(user?.email ?? '',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              decoration: BoxDecoration(color: Colors.blue[700]),
            ),
            ListTile(
              title: const Text('Meus Veículos'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Histórico de Abastecimentos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AbastecimentoHistorico(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Sair'),
              onTap: () {
                authService.signOut();
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Veiculo>>(
        stream: veiculoService.getVeiculos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          final veiculos = snapshot.data!;

          return ListView.builder(
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              final veiculo = veiculos[index];
              return ListTile(
                title: Text(
                  '${veiculo.marca} ${veiculo.modelo}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Placa: ${veiculo.placa} | Ano: ${veiculo.ano}'),
                trailing: TextButton(
                  onPressed: () async {
                    final bool deletar = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar exclusão'),
                            content: Text(
                                'Deseja realmente excluir o veículo ${veiculo.modelo}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        ) ??
                        false;

                    if (deletar && veiculo.id != null) {
                      veiculoService.deleteVeiculo(veiculo.id!);
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Excluir'),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AbastecimentoListaScreen(veiculo: veiculo),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Nenhum veículo cadastrado',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione seu primeiro veículo para começar.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VeiculoForm()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text(
              'Adicionar Veículo',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
