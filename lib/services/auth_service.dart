// SERVICO DE AUTENTICACAO - gerencia login, logout e usuarios
class AuthService {
  // Usuario logado no momento (null se ninguem ta logado)
  static Map<String, dynamic>? _currentUser;

  // ============================================
  // USUARIOS DE DEMONSTRACAO
  // ============================================

  static final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'cpf': '12345678901',
      'nome': 'Bernardo Zilli',
      'dataNascimento': '1990-05-15',
      'pontos': 280,
      'isAdmin': false,
      'todosJogosLiberados': true,
    },
    {
      'id': '2',
      'cpf': '98765432100',
      'nome': 'Luis Antonio',
      'dataNascimento': '1985-08-22',
      'pontos': 250,
      'isAdmin': false,
      'todosJogosLiberados': true,
    },
    {
      'id': '3',
      'cpf': '11122233344',
      'nome': 'Ramon Zilli',
      'dataNascimento': '1992-03-10',
      'pontos': 220,
      'isAdmin': false,
      'todosJogosLiberados': true,
    },
    {
      'id': '4',
      'cpf': '55566677788',
      'nome': 'Carlos Silva',
      'dataNascimento': '1988-12-01',
      'pontos': 200,
      'isAdmin': false,
      'todosJogosLiberados': false,
    },
    {
      'id': '5',
      'cpf': '99988877766',
      'nome': 'Maria Santos',
      'dataNascimento': '1995-07-25',
      'pontos': 180,
      'isAdmin': false,
      'todosJogosLiberados': true,
    },
    {
      'id': '6',
      'cpf': '44433322211',
      'nome': 'Pedro Oliveira',
      'dataNascimento': '1987-03-18',
      'pontos': 160,
      'isAdmin': false,
      'todosJogosLiberados': true,
    },
    {
      'id': '7',
      'cpf': '77788899900',
      'nome': 'Ana Costa',
      'dataNascimento': '1993-09-05',
      'pontos': 140,
      'isAdmin': false,
      'todosJogosLiberados': true,
    },
    {
      'id': 'admin',
      'cpf': '00000000000',
      'nome': 'Administrador',
      'dataNascimento': '1980-01-01',
      'pontos': 0,
      'isAdmin': true,
      'todosJogosLiberados': true,
    },
  ];

  // ============================================
  // METODOS DE USUARIOS
  // ============================================

  static List<Map<String, dynamic>> getAllUsers() {
    return _users.where((u) => u['isAdmin'] != true).toList();
  }

  // ============================================
  // LOGIN (VERSÃO SEGURA)
  // ============================================

  static Map<String, dynamic>? login(String cpf, String dataNascimento) {
    try {
      // 🔍 DEBUG (pode apagar depois)
      print('Tentando login...');
      print('CPF: $cpf');
      print('Data: $dataNascimento');

      final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');

      for (var user in _users) {
        if (user['cpf'] == cpfLimpo && user['dataNascimento'] == dataNascimento) {
          _currentUser = user;

          print('✅ Login OK: ${user['nome']}');

          return user;
        }
      }

      print('❌ Login falhou');

      return null;
    } catch (e) {
      // 🔥 NUNCA DEIXA QUEBRAR O APP
      print('ERRO NO LOGIN: $e');
      return null;
    }
  }

  // ============================================
  // USUARIO ATUAL
  // ============================================

  static Map<String, dynamic>? getCurrentUser() => _currentUser;

  static void logout() {
    _currentUser = null;
  }

  // ============================================
  // ATUALIZAR USUARIO
  // ============================================

  static void updateUser(Map<String, dynamic> updatedUser) {
    final index = _users.indexWhere((u) => u['id'] == updatedUser['id']);
    if (index != -1) {
      _users[index] = updatedUser;
    }
  }
}
