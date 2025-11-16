import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/abastecimento.dart';
import '../../logic/abastecimento_logic.dart';

class AbastecimentoHistorico extends StatelessWidget {
  const AbastecimentoHistorico({super.key});

  @override
  Widget build(BuildContext context) {
    final abastecimentoService = context.watch<AbastecimentoService>();
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico Geral'),
      ),
      body: StreamBuilder<List<Abastecimento>>(
        stream: abastecimentoService.getHistoricoGeral(),
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
                'Nenhum abastecimento registrado.',
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
                  subtitle: Text(
                      '${item.tipoCombustivel} - ${formatter.format(item.data.toDate())}'),
                  trailing:
                      Text('${item.quantidadeLitros.toStringAsFixed(2)} L'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
