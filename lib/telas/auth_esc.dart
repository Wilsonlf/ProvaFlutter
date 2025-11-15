import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'verif/login.dart';
import 'home/home.dart';

class AuthEsc extends StatelessWidget {
  const AuthEsc({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const Home();
    } else {
      return const LoginScreen();
    }
  }
}
