import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/veiculo.dart';
import '../../logic/veiculo_logic.dart';
import 'veiculo_form.dart';

class VeiculosListaScreen extends StatelessWidget {
  const VeiculosListaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final veiculoService = context.watch<VeiculoService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Veículos'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VeiculoForm()),
              );
            },
          ),
        ],
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
            return const Center(
              child: Text('Nenhum veículo cadastrado'),
            );
          }

          final veiculos = snapshot.data!;

          return ListView.builder(
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              final veiculo = veiculos[index];
              return ListTile(
                title: Text('${veiculo.marca} ${veiculo.modelo}'),
                subtitle: Text('Placa: ${veiculo.placa} | Ano: ${veiculo.ano}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final deletar = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Excluir?'),
                            content: Text('Excluir ${veiculo.modelo}?'),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
