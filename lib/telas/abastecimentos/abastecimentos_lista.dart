import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/veiculo.dart';
import '../../models/abastecimento.dart';
import '../../logic/abastecimento_logic.dart';
import 'abastecimento_form.dart';

class AbastecimentoListaScreen extends StatelessWidget {
  final Veiculo veiculo;

  const AbastecimentoListaScreen({super.key, required this.veiculo});

  @override
  Widget build(BuildContext context) {
    final abastecimentoService = context.watch<AbastecimentoService>();
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('${veiculo.modelo} - Abastecimentos'),
      ),
      body: StreamBuilder<List<Abastecimento>>(
        stream: abastecimentoService.getAbastecimentos(veiculo.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum abastecimento registrado.\nToque no "+" para adicionar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final abastecimentos = snapshot.data!;

          return ListView.builder(
            itemCount: abastecimentos.length,
            itemBuilder: (context, index) {
              final item = abastecimentos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.local_gas_station),
                  title: Text(
                    'R\$ ${item.valorPago.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data: ${formatter.format(item.data.toDate())}'),
                      Text(
                          'Litros: ${item.quantidadeLitros.toStringAsFixed(2)} L'),
                      Text('KM: ${item.quilometragem}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error),
                    onPressed: () {
                      abastecimentoService.deleteAbastecimento(
                          veiculo.id!, item.id!);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AbastecimentoForm(veiculo: veiculo),
            ),
          );
        },
      ),
    );
  }
}
