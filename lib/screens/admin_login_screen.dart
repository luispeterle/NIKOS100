import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nikos/services/user_session.dart';
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
  final _userFocusNode = FocusNode();
  final _passFocusNode = FocusNode();

  bool _loading = false;
  bool _showPassword = false;

  Future<void> _login() async {
    if (_loading) return;
    setState(() => _loading = true);

    final resp = await serverPost(
      "login_simple",
      myJson: {
        "nomusu": _userController.text,
        "password": _passController.text,
      },
    );
    if (resp.toString() == 'Erro de login') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            elevation: 8,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Não foi possível entrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Confira seus dados e tente novamente.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
      setState(() => _loading = false);
      return;
    }
    var decodedResponse = jsonDecode(resp);
    var responseData = jsonDecode(decodedResponse['Response'])[0];
    const codususPermitidos = {
      803,
      42,
      66,
      69,
      84,
      95,
      106,
      108,
      113,
      118,
      135,
      142,
      226,
      235,
      240,
      247,
      294,
      302,
      439,
      442,
      984,
      1019,
      1025,
      1042,
      1096,
      1122,
      1188,
      1351,
    };
    final bool isAdmin = responseData["admin"]?.toString().toUpperCase() == "S";

    final codusu = int.tryParse(responseData["codusu"]?.toString() ?? "");

    if (isAdmin || codususPermitidos.contains(codusu)) {
      UserSession.setSession(
        cpf: responseData["cgccpf"],
        nome: '',
        maxPalp: 0,
        totalCompra: 0,
        admin: isAdmin,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminScreen(
            user: {"nome": responseData["nomusu"]},
            onLogout: () {},
            adminId: "admin",
          ),
        ),
      );
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF7A0000),
            margin: const EdgeInsets.all(18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Usuário ou senha inválidos',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _userFocusNode.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3F0000),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFCC0000),
                    Color(0xFF8B0000),
                    Color(0xFF3F0000),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.08),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: -110,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 120,
            left: 32,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.10).withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.10).withValues(alpha: 0.15),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.10).withValues(alpha: 0.35),
                    blurRadius: 22,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 160,
            right: 48,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.amber.withValues(alpha: 0.16).withValues(alpha: 0.85),
                    Colors.amber.withValues(alpha: 0.16).withValues(alpha: 0.15),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.16).withValues(alpha: 0.35),
                    blurRadius: 22,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Acesso restrito",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 34,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFB90000),
                                        Color(0xFF8F0000),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.35),
                                            width: 1.4,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.22),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.admin_panel_settings_rounded,
                                          color: Colors.white,
                                          size: 38,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      const Text(
                                        "Área administrativa",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        "Entre com suas credenciais para continuar",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.78),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Usuário',
                                        style: TextStyle(
                                          color: Colors.grey.shade900,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _userController,
                                        focusNode: _userFocusNode,
                                        autofocus: true,
                                        onSubmitted: (value) {
                                          FocusScope.of(context).requestFocus(_passFocusNode);
                                        },
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF222222),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Digite seu usuário",
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          prefixIcon: Icon(Icons.person_outline_rounded, color: Colors.grey.shade500),
                                          filled: true,
                                          fillColor: const Color(0xFFFAFAFA),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(color: Colors.grey.shade200),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(color: Colors.grey.shade200),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFCC0000),
                                              width: 1.8,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 18),
                                      Text(
                                        'Senha',
                                        style: TextStyle(
                                          color: Colors.grey.shade900,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _passController,
                                        focusNode: _passFocusNode,
                                        obscureText: !_showPassword,
                                        onSubmitted: (value) {
                                          _loading ? null : _login();
                                        },
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF222222),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Digite sua senha',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade500),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() => _showPassword = !_showPassword);
                                            },
                                            icon: Icon(
                                              _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFFAFAFA),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(color: Colors.grey.shade200),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(color: Colors.grey.shade200),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFCC0000),
                                              width: 1.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 26),

                                      SizedBox(
                                        width: double.infinity,
                                        height: 54,
                                        child: ElevatedButton(
                                          onPressed: _loading ? null : _login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFCC0000),
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor: Colors.red.shade200,
                                            elevation: 0,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: _loading
                                              ? const SizedBox(
                                                  height: 22,
                                                  width: 22,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.4,
                                                  ),
                                                )
                                              : const Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.login_rounded, size: 21),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      "ENTRAR",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w900,
                                                        letterSpacing: 1.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F8F8),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: Colors.black.withValues(alpha: 0.06),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 34,
                                              height: 34,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.security_rounded,
                                                color: Color(0xFFCC0000),
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                "Ambiente reservado para configurações e controle interno.",
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 12.5,
                                                  height: 1.35,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Center(
                                        child: Text(
                                          'Versão: $bolaoVersion',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
