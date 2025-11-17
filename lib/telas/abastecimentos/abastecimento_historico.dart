import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/abastecimento.dart';
import '../../logic/abastecimento_logic.dart';

class AbastecimentoHistorico extends StatelessWidget {
  const AbastecimentoHistorico({super.key});

  Map<String, int> _processarDados(List<Abastecimento> abastecimentos) {
    final Map<String, int> counts = {};
    for (final ab in abastecimentos) {
      final placa = ab.veiculoPlaca.isEmpty ? 'Desconhecida' : ab.veiculoPlaca;
      counts[placa] = (counts[placa] ?? 0) + 1;
    }
    return counts;
  }

  Widget _buildChart(BuildContext context, Map<String, int> data) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final int maxValue = data.values.reduce((a, b) => a > b ? a : b);

    final List<BarChartGroupData> barGroups = [];
    int index = 0;
    data.forEach((placa, contagem) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: contagem.toDouble(),
              color: Theme.of(context).colorScheme.primary,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
      index++;
    });

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxValue + 2).toDouble(),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value % 1 != 0 || value == 0)
                    return const SizedBox.shrink();
                  return Text(value.toInt().toString(),
                      style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= data.keys.length) return const SizedBox.shrink();
                  final placa = data.keys.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(placa,
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            ),
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }

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
          final Map<String, int> chartData = _processarDados(abastecimentos);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Abastecimentos por Veículo (Placa)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _buildChart(context, chartData),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: abastecimentos.length,
                  itemBuilder: (context, index) {
                    final item = abastecimentos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.local_gas_station),
                        title: Text(
                          '${item.veiculoPlaca} - R\$ ${item.valorPago.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            '${item.tipoCombustivel} - ${formatter.format(item.data.toDate())}'),
                        trailing: Text(
                            '${item.quantidadeLitros.toStringAsFixed(2)} L'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
