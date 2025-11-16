import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/abastecimento.dart';

class AbastecimentoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid {
    final user = _auth.currentUser;
    return user?.uid;
  }

  CollectionReference<Abastecimento>? _getAbastecimentosRef(String veiculoId) {
    final uid = _uid;
    if (uid == null) return null;
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('veiculos')
        .doc(veiculoId)
        .collection('abastecimentos')
        .withConverter<Abastecimento>(
          fromFirestore: (snapshots, _) =>
              Abastecimento.fromFirestore(snapshots),
          toFirestore: (abastecimento, _) => abastecimento.toJson(),
        );
  }

  Future<void> addAbastecimento(
      String veiculoId, Abastecimento abastecimento) async {
    final ref = _getAbastecimentosRef(veiculoId);
    if (ref == null) return;
    await ref.add(abastecimento);
  }

  Stream<List<Abastecimento>> getAbastecimentos(String veiculoId) {
    final ref = _getAbastecimentosRef(veiculoId);
    if (ref == null) return Stream.value([]);
    return ref
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> deleteAbastecimento(
      String veiculoId, String abastecimentoId) async {
    final ref = _getAbastecimentosRef(veiculoId);
    if (ref == null) return;
    await ref.doc(abastecimentoId).delete();
  }

  Stream<List<Abastecimento>> getHistoricoGeral() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collectionGroup('abastecimentos')
        .where('userId', isEqualTo: uid)
        .withConverter<Abastecimento>(
          fromFirestore: (snapshots, _) =>
              Abastecimento.fromFirestore(snapshots),
          toFirestore: (abastecimento, _) => abastecimento.toJson(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
