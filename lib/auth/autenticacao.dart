import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    }
  }

  Future<String?> signUp({
    required String nome,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      unawaited(userCredential.user?.updateDisplayName(nome));

      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'user-not-found':
        return 'Nenhum usuário encontrado para este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso por outra conta.';
      case 'weak-password':
        return 'A senha fornecida é muito fraca.';
      case 'operation-not-allowed':
        return 'Login com e-mail e senha não está ativado.';
      case 'network-request-failed':
        return 'Erro de rede. Verifique sua conexão com a internet.';
      default:
        return 'Ocorreu um erro desconhecido. Tente novamente.';
    }
  }
}
