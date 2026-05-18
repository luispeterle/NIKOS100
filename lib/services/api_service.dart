import 'dart:convert';
import 'package:flutter/material.dart';

import '../utils/micro_server_post.dart';
import 'user_session.dart';

enum LoginErrorType { none, invalidCpf, transport }

class ApiService {
  static LoginErrorType lastLoginError = LoginErrorType.none;

  static bool _isBackendLoginError(String? value) {
    if (value == null) return false;
    final text = value.trim().toUpperCase();
    return text.contains('ERRO DE LOGIN');
  }

  // ============================================
  // LOGIN
  // ============================================
  static Future<Map<String, dynamic>?> login(String cgccpf) async {
    lastLoginError = LoginErrorType.none;

    await getToken();

    final resp = await serverPost(
      "bolao_login",
      myJson: {
        "cgccpf": cgccpf,
      },
    );

    try {
      if (resp == null || resp == true) {
        final backendLoginError = _isBackendLoginError(lastServerErrorDetail) || _isBackendLoginError(lastServerErrorCode);
        if (backendLoginError) {
          lastLoginError = LoginErrorType.invalidCpf;
        } else {
          lastLoginError = LoginErrorType.transport;
        }
        return null;
      }

      final respText = resp.toString().trim();
      if (respText.toUpperCase() == 'ERRO DE LOGIN') {
        lastLoginError = LoginErrorType.invalidCpf;
        return null;
      }

      final data = jsonDecode(respText);
      final dynamic rawResponse = data['Response'];

      if (rawResponse == null) {
        lastLoginError = LoginErrorType.transport;
        return null;
      }

      if (rawResponse is String && rawResponse.trim().toUpperCase() == 'ERRO DE LOGIN') {
        lastLoginError = LoginErrorType.invalidCpf;
        return null;
      }

      final dynamic decodedResponse = rawResponse is String ? jsonDecode(rawResponse) : rawResponse;

      if (decodedResponse is String && decodedResponse.trim().toUpperCase() == 'ERRO DE LOGIN') {
        lastLoginError = LoginErrorType.invalidCpf;
        return null;
      }

      if (decodedResponse is! List) {
        lastLoginError = LoginErrorType.transport;
        return null;
      }

      final List responseList = decodedResponse;
      if (responseList.isEmpty) {
        lastLoginError = LoginErrorType.invalidCpf;
        return null;
      }

      final userData = responseList[0];
      final maxPalpites = userData['max_palpites'] ?? 25;

      UserSession.setSession(
        cpf: cgccpf,
        nome: userData['nomcli'] ?? '',
        maxPalp: maxPalpites,
        totalCompra: userData['total'] ?? 0,
      );

      return {
        'cpf': userData['cpf']?.toString() ?? cgccpf,
        'max_palpites': maxPalpites,
        'nome': userData['nomcli'] ?? '',
        'total': userData['total'] ?? 0,
        'isAdmin': false,
      };
    } catch (e) {
      debugPrint('Erro no parse do login: $e');
      lastLoginError = LoginErrorType.transport;
      return null;
    }
  }

  // ============================================
  // BUSCAR JOGOS
  // ============================================

  static Future<List<Map<String, dynamic>>> getJogos() async {
    try {
      final resp = await serverPost(
        "bolao_get_jogos",
        myJson: {"cgccpf": UserSession.cgccpf},
      );

      if (resp == true || resp == null) {
        return [];
      }

      final data = jsonDecode(resp);

      if (data['Response'] != null) {
        final List responseList = jsonDecode(data['Response']);

        final jogos = responseList.map<Map<String, dynamic>>((item) {
          final id = int.tryParse('${item['idjogo']}') ?? 0;

          final fase = id >= 1 && id <= 72
              ? 'Fase de grupos'
              : id >= 73 && id <= 88
              ? 'Fase de 32'
              : id >= 89 && id <= 96
              ? 'Oitavas de final'
              : id >= 97 && id <= 100
              ? 'Quartas de final'
              : id >= 101 && id <= 102
              ? 'Semifinal'
              : id == 103
              ? 'Disputa de 3º lugar'
              : id == 104
              ? 'Final'
              : 'Fase não definida';

          return {
            'idjogo': item['idjogo'],
            'fase': fase,

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

        bool semPlacar(v) {
          final texto = v?.toString().trim().toLowerCase() ?? '';
          return texto.isEmpty || texto == 'null';
        }

        int aberto(j) {
          return semPlacar(j['plcraa']) && semPlacar(j['plcrbb']) ? 0 : 1;
        }

        jogos.sort((a, b) {
          final c1 = aberto(a).compareTo(aberto(b));
          if (c1 != 0) return c1;

          final c2 = '${a['datjog'] ?? ''}'.compareTo('${b['datjog'] ?? ''}');
          if (c2 != 0) return c2;

          return (int.tryParse('${a['idjogo']}') ?? 0).compareTo(int.tryParse('${b['idjogo']}') ?? 0);
        });

        return jogos;
      }

      return [];
    } catch (e) {
      debugPrint('Erro ao buscar jogos: $e');
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
          "idjogo": idjogo,
          "palpaa": palpaa,
          "palpbb": palpbb,
        },
      );

      if (resp == true) {
        return false; // Erro
      }

      return true;
    } catch (e) {
      debugPrint('Erro ao salvar palpite: $e');
      return false;
    }
  }

  static Future<bool> salvarJogoAdmin({
    required String idjogo,
    required String datjog,
    required String timeaa,
    required String siglaa,
    required String timebb,
    required String siglbb,
    required String plcraa,
    required String plcrbb,
  }) async {
    try {
      final resp = await serverPost(
        "adm_bolao_salva_jogos",
        myJson: {
          "idjogo": idjogo,
          "datjog": datjog,
          "timeaa": timeaa,
          "siglaa": siglaa,
          "timebb": timebb,
          "siglbb": siglbb,
          "plcraa": plcraa,
          "plcrbb": plcrbb,
        },
      );

      if (resp == true || resp == null) {
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar jogo admin: $e');
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
            'cpfcli': item['cpfcli'] ?? '',
            'nomcli': item['nomcli'],
            'pontos': (item['pontos'] ?? 0).toDouble(),
            'posicao': (item['posicao'] ?? 0).toInt(),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao buscar ranking: $e');
      return [];
    }
  }

  // ============================================
  // COUNT PARTICIPANTES RANKING
  // ============================================
  static Future<List<Map<String, dynamic>>> getCountParticipante() async {
    try {
      final resp = await serverPost(
        "bolao_count_palpites",
        myJson: {},
      );

      if (resp == true || resp == null) {
        return [];
      }

      final data = jsonDecode(resp);
      if (data['Response'] != null) {
        final List responseList = jsonDecode(data['Response']);
        return responseList.map<Map<String, dynamic>>((item) {
          return {
            'totalParticipantes': item['total_cpfs_diferentes'] ?? '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao buscar participantes: $e');
      return [];
    }
  }
}
