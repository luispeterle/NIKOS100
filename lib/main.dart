import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nikos/services/api_service.dart';
import 'package:nikos/utils/micro_server_post.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'services/user_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getToken();
  runApp(const NikosApp());
  if (kIsWeb) unawaited(ApiService.salvaAcessoHomeScreen());
}

class NikosApp extends StatelessWidget {
  const NikosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dá um palpite aí",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFCC0000),
        scaffoldBackgroundColor: const Color(0xFFECEFF1),
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCC0000),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFCC0000),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Map<String, dynamic>? _currentUser;

  void _onLogin(Map<String, dynamic> user) {
    setState(() {
      _currentUser = user;
    });
  }

  void _onLogout() {
    UserSession.clear();
    setState(() {
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // NÃO LOGADO
    if (_currentUser == null) {
      return LoginScreen(onLogin: _onLogin);
    }

    // ADMIN
    if (_currentUser!['isAdmin'] == true) {
      return AdminScreen(
        user: _currentUser!,
        onLogout: _onLogout,
        adminId: _currentUser!['id'] ?? "admin_default",
      );
    }
    // USUÁRIO NORMAL
    return HomeScreen(
      user: _currentUser!,
      onLogout: _onLogout,
    );
  }
}
