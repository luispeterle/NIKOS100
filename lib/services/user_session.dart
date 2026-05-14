class UserSession {
  static String? cgccpf;
  static String? nome;
  static int? maxPalpites;
  static int palpitesFeitos = 0;
  static double totalCompra = 0;

  static void setSession({
    required String cpf,
    required String nome,
    required int maxPalp,
    required double totalCompra,
  }) {
    cgccpf = cpf;
    UserSession.nome = nome;
    maxPalpites = maxPalp;
    palpitesFeitos = 0;
    UserSession.totalCompra = totalCompra;
  }

  static void clear() {
    cgccpf = null;
    nome = null;
    maxPalpites = null;
    palpitesFeitos = 0;
    totalCompra = 0;
  }

  static bool get isLoggedIn => cgccpf != null;

  static bool canMakePalpite() {
    if (maxPalpites == null) return false;
    return palpitesFeitos < maxPalpites!;
  }
}
