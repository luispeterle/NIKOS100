import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nikos/utils/micro_server_post.dart';
import 'admin_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  Future<void> _login() async {
    final resp = await serverPost(
      "login_simple",
      myJson: {
        "nomusu": _userController.text,
        "password": _passController.text,
      },
    );
    var decodedResponse = jsonDecode(resp);
    var responseData = jsonDecode(decodedResponse['Response'])[0];

    if (responseData["admin"] == "S" || true) {
      // Remover o || true depois
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminScreen(
            user: {"nome": "Admin"},
            onLogout: () {},
            adminId: "admin",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login inválido")),
      );
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acesso restrito"),
        backgroundColor: const Color(0xFFCC0000),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "Usuário",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCC0000),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Entrar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
