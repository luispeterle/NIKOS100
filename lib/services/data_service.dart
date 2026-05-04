import '../services/auth_service.dart';

class DataService {
  static final List<Map<String, dynamic>> _jogos = _gerarJogosDemonstracao();
  static final List<Map<String, dynamic>> _palpites = [];
  static final List<Map<String, dynamic>> _logs = [];
  static DateTime? _rankingCacheTime;

  // ============================================
  // MAPA DE BANDEIRAS
  // ============================================

  static final Map<String, String> _bandeiras = {
    'Brasil': 'BR',
    'Argentina': 'AR',
    'EUA': 'US',
    'Mexico': 'MX',
    'Canada': 'CA',
    'Costa Rica': 'CR',
    'Franca': 'FR',
    'Alemanha': 'DE',
    'Italia': 'IT',
    'Espanha': 'ES',
    'Inglaterra': 'GB',
    'Holanda': 'NL',
    'Belgica': 'BE',
    'Croacia': 'HR',
    'Portugal': 'PT',
    'Uruguai': 'UY',
    'Colombia': 'CO',
    'Equador': 'EC',
    'Japao': 'JP',
    'Coreia do Sul': 'KR',
    'Australia': 'AU',
    'Nova Zelandia': 'NZ',
    'Nigeria': 'NG',
    'Senegal': 'SN',
    'Marrocos': 'MA',
    'Gana': 'GH',
    'Arabia Saudita': 'SA',
    'Ira': 'IR',
    'Qatar': 'QA',
    'Emirados Arabes': 'AE',
    'Polonia': 'PL',
    'Servia': 'RS',
    'Suica': 'CH',
    'Dinamarca': 'DK',
    'Suecia': 'SE',
    'Noruega': 'NO',
    'Finlandia': 'FI',
    'Islandia': 'IS',
    'Turquia': 'TR',
    'Grecia': 'GR',
    'Republica Tcheca': 'CZ',
    'Hungria': 'HU',
    'Escocia': 'GB',
    'Irlanda': 'IE',
    'Pais de Gales': 'GB',
    'Ucrania': 'UA',
    'Chile': 'CL',
    'Peru': 'PE',
  };

  static String getBandeira(String pais) {
    final code = _bandeiras[pais];
    if (code == null) return '';

    return code.toLowerCase();
  }

  // ============================================
  // GERADOR DE JOGOS
  // ============================================

  static List<Map<String, dynamic>> _gerarJogosDemonstracao() {
    final jogos = <Map<String, dynamic>>[];
    int jogoId = 1;

    final grupos = {
      'A': ['EUA', 'Mexico', 'Costa Rica', 'Canada'],
      'B': ['Brasil', 'Argentina', 'Chile', 'Peru'],
      'C': ['Franca', 'Alemanha', 'Italia', 'Espanha'],
      'D': ['Inglaterra', 'Holanda', 'Belgica', 'Croacia'],
      'E': ['Portugal', 'Uruguai', 'Colombia', 'Equador'],
      'F': ['Japao', 'Coreia do Sul', 'Australia', 'Nova Zelandia'],
      'G': ['Nigeria', 'Senegal', 'Marrocos', 'Gana'],
      'H': ['Arabia Saudita', 'Ira', 'Qatar', 'Emirados Arabes'],
      'I': ['Polonia', 'Servia', 'Suica', 'Dinamarca'],
      'J': ['Suecia', 'Noruega', 'Finlandia', 'Islandia'],
      'K': ['Turquia', 'Grecia', 'Republica Tcheca', 'Hungria'],
      'L': ['Escocia', 'Irlanda', 'Pais de Gales', 'Ucrania'],
    };

    var dataBase = DateTime(2026, 6, 11, 13, 0);
    int jogoNum = 0;

    grupos.forEach((grupo, times) {
      for (int i = 0; i < times.length; i++) {
        for (int j = i + 1; j < times.length; j++) {
          final time1 = times[i];
          final time2 = times[j];

          final isBrasil = time1 == 'Brasil' || time2 == 'Brasil';

          jogos.add({
            'id': '${jogoId++}',
            'time1': time1,
            'time2': time2,
            'bandeira1': getBandeira(time1),
            'bandeira2': getBandeira(time2),
            'dataHora': dataBase.add(Duration(hours: jogoNum * 4)).toIso8601String(),
            'fase': 'Fase de Grupos',
            'grupo': 'Grupo $grupo',
            'golsTime1': null,
            'golsTime2': null,
            'finalizado': false,
            'dobroPontos': isBrasil,
            'jogoDoBrasil': isBrasil,
          });
          jogoNum++;
        }
      }
    });

    // OITAVAS
    for (int i = 0; i < 8; i++) {
      jogos.add({
        'id': '${jogoId++}',
        'time1': '1º Grupo ${String.fromCharCode(65 + i)}',
        'time2': '2º Grupo ${String.fromCharCode(65 + ((i + 1) % 8))}',
        'bandeira1': '',
        'bandeira2': '',
        'dataHora': dataBase.add(Duration(hours: jogoNum * 4)).toIso8601String(),
        'fase': 'Oitavas de Final',
        'grupo': '',
        'golsTime1': null,
        'golsTime2': null,
        'finalizado': false,
        'dobroPontos': false,
        'jogoDoBrasil': false,
      });
      jogoNum++;
    }

    // QUARTAS
    for (int i = 0; i < 4; i++) {
      jogos.add({
        'id': '${jogoId++}',
        'time1': 'Vencedor Oitavas ${i * 2 + 1}',
        'time2': 'Vencedor Oitavas ${i * 2 + 2}',
        'bandeira1': '',
        'bandeira2': '',
        'dataHora': dataBase.add(Duration(hours: jogoNum * 4)).toIso8601String(),
        'fase': 'Quartas de Final',
        'grupo': '',
        'golsTime1': null,
        'golsTime2': null,
        'finalizado': false,
        'dobroPontos': false,
        'jogoDoBrasil': false,
      });
      jogoNum++;
    }

    // SEMIS
    for (int i = 0; i < 2; i++) {
      jogos.add({
        'id': '${jogoId++}',
        'time1': 'Vencedor Quartas ${i * 2 + 1}',
        'time2': 'Vencedor Quartas ${i * 2 + 2}',
        'bandeira1': '',
        'bandeira2': '',
        'dataHora': dataBase.add(Duration(hours: jogoNum * 4)).toIso8601String(),
        'fase': 'Semifinal',
        'grupo': '',
        'golsTime1': null,
        'golsTime2': null,
        'finalizado': false,
        'dobroPontos': false,
        'jogoDoBrasil': false,
      });
      jogoNum++;
    }

    // 3º LUGAR
    jogos.add({
      'id': '${jogoId++}',
      'time1': 'Perdedor Semi 1',
      'time2': 'Perdedor Semi 2',
      'bandeira1': '',
      'bandeira2': '',
      'dataHora': dataBase.add(Duration(hours: jogoNum * 4)).toIso8601String(),
      'fase': 'Disputa 3º Lugar',
      'grupo': '',
      'golsTime1': null,
      'golsTime2': null,
      'finalizado': false,
      'dobroPontos': false,
      'jogoDoBrasil': false,
    });

    jogoNum++;

    // FINAL
    jogos.add({
      'id': '${jogoId++}',
      'time1': 'Vencedor Semi 1',
      'time2': 'Vencedor Semi 2',
      'bandeira1': '',
      'bandeira2': '',
      'dataHora': dataBase.add(Duration(hours: jogoNum * 4)).toIso8601String(),
      'fase': 'Final',
      'grupo': '',
      'golsTime1': null,
      'golsTime2': null,
      'finalizado': false,
      'dobroPontos': true,
      'jogoDoBrasil': false,
    });

    return jogos;
  }


  static List<Map<String, dynamic>> getJogos() => _jogos;

  static void updateJogo(Map<String, dynamic> jogo) {
    final index = _jogos.indexWhere((j) => j['id'] == jogo['id']);
    if (index != -1) {
      _jogos[index] = jogo;
    }
  }

  static void addJogo(Map<String, dynamic> jogo) {
    _jogos.add(jogo);
  }

  static void deleteJogo(String jogoId) {
    _jogos.removeWhere((j) => j['id'] == jogoId);
  }

  static List<Map<String, dynamic>> getPalpites() => _palpites;

  static Map<String, dynamic>? getPalpiteByUserAndJogo(
    String userId,
    String jogoId,
  ) {
    try {
      return _palpites.firstWhere(
        (p) => p['usuarioId'] == userId && p['jogoId'] == jogoId,
      );
    } catch (_) {
      return null;
    }
  }

  static void savePalpite(Map<String, dynamic> palpite) {
    final index = _palpites.indexWhere(
      (p) => p['usuarioId'] == palpite['usuarioId'] && p['jogoId'] == palpite['jogoId'],
    );

    if (index != -1) {
      _palpites[index] = palpite;
    } else {
      _palpites.add(palpite);
    }
  }

  static List<Map<String, dynamic>> getRanking({bool forceRefresh = false}) {
    final users = AuthService.getAllUsers();

    users.sort((a, b) => (b['pontos'] as int).compareTo(a['pontos'] as int));

    final ranking = <Map<String, dynamic>>[];
    for (int i = 0; i < users.length; i++) {
      ranking.add({
        'posicao': i + 1,
        'nome': users[i]['nome'],
        'pontos': users[i]['pontos'],
        'userId': users[i]['id'],
      });
    }

    _rankingCacheTime = DateTime.now();
    return ranking;
  }

  static DateTime? getRankingCacheTime() => _rankingCacheTime;

  static void addLog(String action, String details, String adminId) {
    _logs.insert(0, {
      'id': '${_logs.length + 1}',
      'action': action,
      'details': details,
      'adminId': adminId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (_logs.length > 100) {
      _logs.removeRange(100, _logs.length);
    }
  }

  static List<Map<String, dynamic>> getLogs() => _logs;
}
