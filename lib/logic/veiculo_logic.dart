import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/veiculo.dart';

class VeiculoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid {
    final user = _auth.currentUser;
    return user?.uid;
  }

  CollectionReference<Veiculo>? get _veiculosRef {
    final uid = _uid;
    if (uid == null) return null;

    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('veiculos')
        .withConverter<Veiculo>(
          fromFirestore: (snapshots, _) => Veiculo.fromFirestore(snapshots),
          toFirestore: (veiculo, _) => veiculo.toJson(),
        );
  }

  Future<void> addVeiculo(Veiculo veiculo) async {
    if (_veiculosRef == null) return;
    await _veiculosRef!.add(veiculo);
  }

  Stream<List<Veiculo>> getVeiculos() {
    final ref = _veiculosRef;
    if (ref == null) {
      return Stream.value([]);
    }

    return ref
        .orderBy('marca')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> deleteVeiculo(String veiculoId) async {
    if (_veiculosRef == null) return;
    await _veiculosRef!.doc(veiculoId).delete();
  }
}
