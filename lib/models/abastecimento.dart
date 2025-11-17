import 'package:cloud_firestore/cloud_firestore.dart';

class Abastecimento {
  final String? id;
  final String userId;
  final Timestamp data;
  final double quantidadeLitros;
  final double valorPago;
  final int quilometragem;
  final String tipoCombustivel;
  final String? observacao;
  final String veiculoId;
  final String veiculoNome;
  final String veiculoPlaca;

  Abastecimento({
    this.id,
    required this.userId,
    required this.data,
    required this.quantidadeLitros,
    required this.valorPago,
    required this.quilometragem,
    required this.tipoCombustivel,
    this.observacao,
    required this.veiculoId,
    required this.veiculoNome,
    required this.veiculoPlaca,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'data': data,
      'quantidadeLitros': quantidadeLitros,
      'valorPago': valorPago,
      'quilometragem': quilometragem,
      'tipoCombustivel': tipoCombustivel,
      'observacao': observacao,
      'veiculoId': veiculoId,
      'veiculoNome': veiculoNome,
      'veiculoPlaca': veiculoPlaca,
    };
  }

  factory Abastecimento.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Abastecimento(
      id: doc.id,
      userId: data['userId'] ?? '',
      data: data['data'] as Timestamp,
      quantidadeLitros: (data['quantidadeLitros'] ?? 0.0).toDouble(),
      valorPago: (data['valorPago'] ?? 0.0).toDouble(),
      quilometragem: data['quilometragem'] ?? 0,
      tipoCombustivel: data['tipoCombustivel'] ?? '',
      observacao: data['observacao'],
      veiculoId: data['veiculoId'] ?? '',
      veiculoNome: data['veiculoNome'] ?? '',
      veiculoPlaca: data['veiculoPlaca'] ?? '',
    );
  }

  double get valorPorLitro {
    if (quantidadeLitros == 0) return 0.0;
    return valorPago / quantidadeLitros;
  }
}
