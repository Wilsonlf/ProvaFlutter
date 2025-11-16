import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      print("ERRO GENÉRICO NO LOGIN: $e");
      return 'Ocorreu um erro desconhecido.';
    }
  }

  // Método de Cadastro
  Future<String?> signUp(
      {required String nome,
      required String email,
      required String password}) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      try {
        if (userCredential.user != null) {
          await userCredential.user?.updateDisplayName(nome);
        }
      } catch (e) {
        print(
            "AVISO: Usuário $email foi criado, mas falha ao salvar o nome: $e");
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print("ERRO DE FIREBASE AUTH: ${e.code}");
      return e.message;
    } catch (e) {
      print("ERRO GENÉRICO NO CADASTRO: $e");
      return 'Ocorreu um erro desconhecido.';
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
