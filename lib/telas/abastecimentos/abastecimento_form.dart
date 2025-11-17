import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/veiculo.dart';
import '../../models/abastecimento.dart';
import '../../logic/abastecimento_logic.dart';
import '../../auth/autenticacao.dart';

class AbastecimentoForm extends StatefulWidget {
  final Veiculo veiculo;
  const AbastecimentoForm({super.key, required this.veiculo});

  @override
  State<AbastecimentoForm> createState() => _AbastecimentoFormState();
}

class _AbastecimentoFormState extends State<AbastecimentoForm> {
  final _formKey = GlobalKey<FormState>();
  final _litrosController = TextEditingController();
  final _valorPagoController = TextEditingController();
  final _kmController = TextEditingController();
  final _obsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _litrosController.dispose();
    _valorPagoController.dispose();
    _kmController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _salvarAbastecimento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final userId = authService.currentUser?.uid;

      if (userId == null) {
        throw Exception('Usuário não autenticado.');
      }

      final abastecimentoService = context.read<AbastecimentoService>();

      final novoAbastecimento = Abastecimento(
        userId: userId,
        data: Timestamp.now(),
        quantidadeLitros: double.parse(_litrosController.text),
        valorPago: double.parse(_valorPagoController.text),
        quilometragem: int.parse(_kmController.text),
        tipoCombustivel: widget.veiculo.tipoCombustivel,
        observacao: _obsController.text,
        veiculoId: widget.veiculo.id!,
        veiculoNome: "${widget.veiculo.marca} ${widget.veiculo.modelo}",
        veiculoPlaca: widget.veiculo.placa,
      );

      await abastecimentoService.addAbastecimento(
          widget.veiculo.id!, novoAbastecimento);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abastecimento salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Abastecimento (${widget.veiculo.modelo})'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _kmController,
                  decoration: const InputDecoration(
                    labelText: 'Quilometragem (KM)',
                    prefixIcon: Icon(Icons.speed),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe a KM';
                    if (int.tryParse(value) == null) return 'Número inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _litrosController,
                  decoration: const InputDecoration(
                    labelText: 'Litros (L)',
                    prefixIcon: Icon(Icons.local_gas_station),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Informe os litros';
                    if (double.tryParse(value) == null)
                      return 'Número inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valorPagoController,
                  decoration: const InputDecoration(
                    labelText: 'Valor Pago (R\$)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Informe o valor';
                    if (double.tryParse(value) == null)
                      return 'Número inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _obsController,
                  decoration: const InputDecoration(
                    labelText: 'Observação - Opcional',
                    prefixIcon: Icon(Icons.note),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isLoading ? null : _salvarAbastecimento,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white))
                      : const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
