import 'dart:convert';
import '../utils/micro_server_post.dart';
import 'user_session.dart';

class ApiService {
  // ============================================
  // LOGIN
  // ============================================
  static Future<Map<String, dynamic>?> login(String cgccpf, String nascimento) async {
    try {
      final resp = await serverPost(
        "bolao_login",
        myJson: {
          "cgccpf": cgccpf,
          "nascimento": nascimento,
        },
      );
      if (resp == true || resp == null) {
        return null; // Erro
      }

      final data = jsonDecode(resp);
      if (data['Response'] != null) {
        final List responseList = jsonDecode(data['Response']);
        if (responseList.isNotEmpty) {
          final userData = responseList[0];
          final maxPalpites = userData['max_palpites'] ?? 25;

          // Salvar na sessão global
          UserSession.setSession(
            cpf: cgccpf,
            dataNascimento: nascimento,
            maxPalp: maxPalpites,
          );

          return {
            'cpf': userData['cpf']?.toString() ?? cgccpf,
            'max_palpites': maxPalpites,
            'nome': 'Usuário',
            'isAdmin': false,
          };
        }
      }
      return null;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  // ============================================
  // BUSCAR JOGOS
  // ============================================
  static Future<List<Map<String, dynamic>>> getJogos() async {
    try {
      final resp = await serverPost("bolao_get_jogos", myJson: {"cgccpf": UserSession.cgccpf});

      if (resp == true || resp == null) {
        return [];
      }

      final data = jsonDecode(resp);
      if (data['Response'] != null) {
        final List responseList = jsonDecode(data['Response']);
        return responseList.map<Map<String, dynamic>>((item) {
          return {
            'idjogo': item['idjogo'],
            'datjog': item['datjog'],
            'timeaa': item['timeaa'],
            'siglaa': item['siglaa'],
            'timebb': item['timebb'],
            'siglbb': item['siglbb'],
            'plcraa': item['plcraa'],
            'plcrbb': item['plcrbb'],
            'usupla': item['usupla'],
            'usuplb': item['usuplb'],
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar jogos: $e');
      return [];
    }
  }

  // ============================================
  // SALVAR PALPITE
  // ============================================
  static Future<bool> salvarPalpite({
    required String idjogo,
    required String palpaa,
    required String palpbb,
  }) async {
    if (!UserSession.isLoggedIn) return false;

    try {
      final resp = await serverPost(
        "bolao_salva_palpite",
        myJson: {
          "cgccpf": UserSession.cgccpf,
          "nascimento": UserSession.nascimento,
          "idjogo": idjogo,
          "palpaa": palpaa,
          "palpbb": palpbb,
        },
      );

      if (resp == true) {
        return false; // Erro
      }

      UserSession.palpitesFeitos++;
      return true;
    } catch (e) {
      print('Erro ao salvar palpite: $e');
      return false;
    }
  }

  // ============================================
  // BUSCAR RANKING
  // ============================================
  static Future<List<Map<String, dynamic>>> getRanking() async {
    try {
      final resp = await serverPost(
        "bolao_rank",
        myJson: {
          "cgccpf": UserSession.cgccpf ?? "",
        },
      );

      if (resp == true || resp == null) {
        return [];
      }

      final data = jsonDecode(resp);
      if (data['Response'] != null) {
        final List responseList = jsonDecode(data['Response']);
        return responseList.map<Map<String, dynamic>>((item) {
          return {
            'nomcli': item['nomcli'],
            'pontos': (item['pontos'] ?? 0).toDouble(),
            'posicao': (item['posicao'] ?? 0).toInt(),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar ranking: $e');
      return [];
    }
  }
}
