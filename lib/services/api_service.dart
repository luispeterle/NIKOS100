import 'dart:convert';
import 'package:flutter/material.dart';

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
            nome: userData['nomcli'] ?? '',
            maxPalp: maxPalpites,
          );

          return {
            'cpf': userData['cpf']?.toString() ?? cgccpf,
            'max_palpites': maxPalpites,
            'nome': userData['nomcli'] ?? '',
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

        final jogos = responseList.map<Map<String, dynamic>>((item) {
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

        jogos.sort((a, b) {
          final dataA = (a['datjog']);
          final dataB = (b['datjog']);

          final compareData = dataA.compareTo(dataB);

          if (compareData != 0) {
            return compareData;
          }

          final idA = int.tryParse(a['idjogo'].toString()) ?? 0;
          final idB = int.tryParse(b['idjogo'].toString()) ?? 0;

          return idA.compareTo(idB);
        });

        return jogos;
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
