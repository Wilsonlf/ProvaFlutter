import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/veiculo.dart';
import '../../logic/veiculo_logic.dart'; // <-- CORREÇÃO AQUI (era 'services/')

class VeiculoForm extends StatefulWidget {
  const VeiculoForm({super.key});

  @override
  State<VeiculoForm> createState() => _VeiculoFormState();
}

class _VeiculoFormState extends State<VeiculoForm> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos
  final _modeloController = TextEditingController();
  final _marcaController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();

  // Valor selecionado no Dropdown
  String? _tipoCombustivelSelecionado;
  final List<String> _tiposCombustivel = [
    'Gasolina',
    'Álcool',
    'Diesel',
    'GNV',
    'Elétrico',
    'Flex'
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _modeloController.dispose();
    _marcaController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  Future<void> _salvarVeiculo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final veiculoService = context.read<VeiculoService>();

      final novoVeiculo = Veiculo(
        modelo: _modeloController.text,
        marca: _marcaController.text,
        placa: _placaController.text,
        ano: _anoController.text,
        tipoCombustivel: _tipoCombustivelSelecionado!,
      );

      await veiculoService.addVeiculo(novoVeiculo);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veículo salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar veículo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Veículo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Marca
                TextFormField(
                  controller: _marcaController,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe a marca';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Modelo
                TextFormField(
                  controller: _modeloController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    prefixIcon: Icon(Icons.directions_car_filled),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe o modelo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _placaController,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    prefixIcon: Icon(Icons.pin),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe a placa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ano
                TextFormField(
                  controller: _anoController,
                  decoration: const InputDecoration(
                    labelText: 'Ano',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe o ano';
                    }
                    if (int.tryParse(value) == null || value.length != 4) {
                      return 'Informe um ano válido (ex: 2023)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _tipoCombustivelSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Combustível',
                    prefixIcon: Icon(Icons.local_gas_station),
                  ),
                  items: _tiposCombustivel.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipoCombustivelSelecionado = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione o combustível';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                FilledButton(
                  onPressed: _isLoading ? null : _salvarVeiculo,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
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
