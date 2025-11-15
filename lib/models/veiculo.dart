import 'package:cloud_firestore/cloud_firestore.dart';

class Veiculo {
  final String? id;
  final String modelo;
  final String marca;
  final String placa;
  final String ano;
  final String tipoCombustivel;

  Veiculo({
    this.id,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.ano,
    required this.tipoCombustivel,
  });

  Map<String, dynamic> toJson() {
    return {
      'modelo': modelo,
      'marca': marca,
      'placa': placa,
      'ano': ano,
      'tipoCombustivel': tipoCombustivel,
    };
  }

  factory Veiculo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Veiculo(
      id: doc.id,
      modelo: data['modelo'] ?? '',
      marca: data['marca'] ?? '',
      placa: data['placa'] ?? '',
      ano: data['ano'] ?? '',
      tipoCombustivel: data['tipoCombustivel'] ?? '',
    );
  }
}
