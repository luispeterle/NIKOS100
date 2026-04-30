// sessão global do usuário - armazena credenciais para requisição
class UserSession {
  static String? cgccpf;
  static String? nascimento;
  static String? nome;
  static int? maxPalpites;
  static int palpitesFeitos = 0;

  static void setSession({
    required String cpf,
    required String dataNascimento,
    required String nome,
    required int maxPalp,
  }) {
    cgccpf = cpf;
    nascimento = dataNascimento;
    nome = nome;
    maxPalpites = maxPalp;
    palpitesFeitos = 0;
  }

  static void clear() {
    cgccpf = null;
    nascimento = null;
    nome = null;
    maxPalpites = null;
    palpitesFeitos = 0;
  }

  static bool get isLoggedIn => cgccpf != null && nascimento != null;

  static bool canMakePalpite() {
    if (maxPalpites == null) return false;
    return palpitesFeitos < maxPalpites!;
  }
}
