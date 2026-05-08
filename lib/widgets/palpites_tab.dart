import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nikos/utils/date_utils.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';

class PalpitesTab extends StatefulWidget {
  final Map<String, dynamic> user;

  const PalpitesTab({super.key, required this.user});

  @override
  State<PalpitesTab> createState() => _PalpitesTabState();
}

class _PalpitesTabState extends State<PalpitesTab> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _jogos = [];
  final Map<int, Map<String, dynamic>> _palpitesLocais = {};

  final ScrollController _scrollController = ScrollController();
  final Map<int, Timer> _autoSaveTimers = {};
  final Map<int, Timer> _salvoAgoraTimers = {};
  final Map<int, DateTime> _salvoAgoraPorJogo = {};
  final Map<int, TextEditingController> _gol1Controllers = {};
  final Map<int, TextEditingController> _gol2Controllers = {};
  final Map<int, FocusNode> _gol1FocusNodes = {};
  final Map<int, FocusNode> _gol2FocusNodes = {};
  final Map<int, bool> _salvandoPalpite = {};
  final Map<int, GlobalKey> _jogoCardKeys = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final timer in _autoSaveTimers.values) {
      timer.cancel();
    }
    for (final timer in _salvoAgoraTimers.values) {
      timer.cancel();
    }
    for (final controller in _gol1Controllers.values) {
      controller.dispose();
    }
    for (final controller in _gol2Controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _gol1FocusNodes.values) {
      focusNode.dispose();
    }
    for (final focusNode in _gol2FocusNodes.values) {
      focusNode.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final jogos = await ApiService.getJogos();

    setState(() {
      _jogos = jogos;
      _loading = false;
    });
  }

  String _getSiglaParaBandeira(String sigla) {
    final Map<String, String> siglaParaCodigo = {
      'QAT': 'qa',
      'ECU': 'ec',
      'ENG': 'gb-eng',
      'IRN': 'ir',
      'ARG': 'ar',
      'KSA': 'sa',
      'GER': 'de',
      'JPN': 'jp',
      'BRA': 'br',
      'SRB': 'rs',
      'POR': 'pt',
      'GHA': 'gh',
      'FRA': 'fr',
      'DEN': 'dk',
      'ESP': 'es',
      'CRO': 'hr',
      'NED': 'nl',
      'USA': 'us',
      'MAR': 'ma',
      'BEL': 'be',
      'MEX': 'mx',
      'CAN': 'ca',
      'ITA': 'it',
      'URU': 'uy',
      'COL': 'co',
      'CHI': 'cl',
      'PER': 'pe',
      'KOR': 'kr',
      'AUS': 'au',
      'NZL': 'nz',
      'NGA': 'ng',
      'SEN': 'sn',
      'UAE': 'ae',
      'POL': 'pl',
      'SUI': 'ch',
      'SWE': 'se',
      'NOR': 'no',
      'FIN': 'fi',
      'ISL': 'is',
      'TUR': 'tr',
      'GRE': 'gr',
      'CZE': 'cz',
      'HUN': 'hu',
      'SCO': 'gb-sct',
      'IRL': 'ie',
      'WAL': 'gb-wls',
      'UKR': 'ua',
      'CRC': 'cr',
      'RSA': 'za',
      'BIH': 'ba',
      'PAR': 'py',
      'HAI': 'ht',
      'CUW': 'cw',
      'CIV': 'ci',
      'TUN': 'tn',
      'CPV': 'cv',
      'EGY': 'eg',
      'AUT': 'at',
      'JOR': 'jo',
      'IRQ': 'iq',
      'ALG': 'dz',
      'COD': 'cd',
      'PAN': 'pa',
      'UZB': 'uz',
    };

    final codigo = siglaParaCodigo[sigla.toUpperCase()];
    if (codigo != null) {
      return codigo;
    }

    if (sigla.length == 2) {
      return sigla.toLowerCase();
    }

    return '';
  }

  Widget _getBandeira(String sigla) {
    if (sigla.isEmpty) {
      return Container(
        width: 50,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.flag, color: Colors.grey, size: 20),
      );
    }

    final codigo = _getSiglaParaBandeira(sigla);
    if (codigo.isEmpty) {
      return Container(
        width: 50,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            sigla,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          'https://flagcdn.com/w80/$codigo.png',
          width: 50,
          height: 35,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: 50,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                sigla,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _podeEditarPalpite(String datjog) {
    final dataJogo = tryParseDatjog(datjog);
    if (dataJogo == null) return false;

    final agora = DateTime.now();
    final limiteEdicao = dataJogo.subtract(const Duration(hours: 1));

    return !agora.isAfter(limiteEdicao);
  }

  bool _placarDefinido(dynamic value) {
    if (value == null) return false;
    final texto = value.toString().trim();
    if (texto.isEmpty || texto.toLowerCase() == 'null') return false;
    return int.tryParse(texto) != null;
  }

  String _formatarData(String datjog) {
    try {
      final partes = datjog.split(' ');
      final dataPartes = partes[0].split('-');
      final hora = partes[1].substring(0, 5);
      return '${dataPartes[2]}/${dataPartes[1]} $hora';
    } catch (e) {
      return datjog;
    }
  }

  bool _ehJogoDoBrasil(Map<String, dynamic> jogo) {
    final siglaa = (jogo['siglaa'] ?? '').toString().toUpperCase();
    final siglbb = (jogo['siglbb'] ?? '').toString().toUpperCase();
    return siglaa == 'BRA' || siglbb == 'BRA';
  }

  TextEditingController _obterControllerGol({
    required int idjogo,
    required bool primeiroGol,
    required String valorInicial,
  }) {
    final mapa = primeiroGol ? _gol1Controllers : _gol2Controllers;
    final controller = mapa.putIfAbsent(idjogo, () => TextEditingController(text: valorInicial));

    if (controller.text.trim().isEmpty && valorInicial.trim().isNotEmpty) {
      controller.text = valorInicial;
    }

    return controller;
  }

  FocusNode _obterFocusNodeGol({
    required int idjogo,
    required bool primeiroGol,
  }) {
    final mapa = primeiroGol ? _gol1FocusNodes : _gol2FocusNodes;
    return mapa.putIfAbsent(
      idjogo,
      () => FocusNode(debugLabel: primeiroGol ? 'gol1-$idjogo' : 'gol2-$idjogo'),
    );
  }

  void _marcarPalpiteSalvoAgora(int idjogo) {
    _salvoAgoraTimers[idjogo]?.cancel();

    setState(() {
      _salvoAgoraPorJogo[idjogo] = DateTime.now();
    });

    _salvoAgoraTimers[idjogo] = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _salvoAgoraPorJogo.remove(idjogo);
      });
    });
  }

  GlobalKey _obterCardKey(int idjogo) {
    return _jogoCardKeys.putIfAbsent(
      idjogo,
      () => GlobalKey(debugLabel: 'jogo-card-$idjogo'),
    );
  }

  bool _jogoPodeReceberPalpite(Map<String, dynamic> jogo) {
    final datjog = (jogo['datjog'] ?? '').toString();
    final podeEditar = _podeEditarPalpite(datjog);
    if (!podeEditar) return false;

    final idjogo = int.tryParse('${jogo['idjogo']}') ?? 0;
    if (idjogo <= 0) return false;

    final usupla = jogo['usupla'];
    final usuplb = jogo['usuplb'];
    final palpiteServidor = usupla != null && usuplb != null
        ? {
            'palpaa': usupla,
            'palpbb': usuplb,
          }
        : null;
    final palpiteAtual = _palpitesLocais[idjogo] ?? palpiteServidor;

    return UserSession.canMakePalpite() || palpiteAtual != null;
  }

  int? _obterProximoJogoElegivelId(int idjogoAtual) {
    final indiceAtual = _jogos.indexWhere(
      (jogo) => int.tryParse('${jogo['idjogo']}') == idjogoAtual,
    );
    if (indiceAtual < 0) return null;

    for (int i = indiceAtual + 1; i < _jogos.length; i++) {
      final jogo = _jogos[i];
      final id = int.tryParse('${jogo['idjogo']}') ?? 0;
      if (id <= 0) continue;
      if (_jogoPodeReceberPalpite(jogo)) {
        return id;
      }
    }

    return null;
  }

  Future<void> _rolarParaProximoPalpite(int idjogoAtual) async {
    if (!mounted || !_scrollController.hasClients) return;

    final idProximoJogo = _obterProximoJogoElegivelId(idjogoAtual);
    if (idProximoJogo == null) return;

    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted || !_scrollController.hasClients) return;

    final proximoContexto = _obterCardKey(idProximoJogo).currentContext;
    if (proximoContexto != null) {
      if (!proximoContexto.mounted) return;
      await Scrollable.ensureVisible(
        proximoContexto,
        alignment: 0.08,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    final atualContexto = _obterCardKey(idjogoAtual).currentContext;
    final renderAtual = atualContexto?.findRenderObject();
    if (renderAtual is! RenderBox) return;

    final deslocamentoEstimado = renderAtual.size.height + 14;
    final destino = (_scrollController.offset + deslocamentoEstimado).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    await _scrollController.animateTo(
      destino,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _irParaProximoJogoComTab({
    required int idjogoAtual,
    required TextEditingController gol1Controller,
    required TextEditingController gol2Controller,
    required Map<String, dynamic>? palpiteAtual,
  }) async {
    if (!mounted) return;

    _autoSaveTimers[idjogoAtual]?.cancel();

    await _salvarPalpiteDoJogo(
      idjogo: idjogoAtual,
      palpaa: gol1Controller.text,
      palpbb: gol2Controller.text,
      palpiteAtual: palpiteAtual,
      mostrarFeedback: false,
    );

    if (!mounted) return;

    final idProximoJogo = _obterProximoJogoElegivelId(idjogoAtual);
    if (idProximoJogo == null) return;

    await _rolarParaProximoPalpite(idjogoAtual);
    if (!mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    _obterFocusNodeGol(idjogo: idProximoJogo, primeiroGol: true).requestFocus();
  }

  Future<void> _salvarPalpiteDoJogo({
    required int idjogo,
    required String palpaa,
    required String palpbb,
    required Map<String, dynamic>? palpiteAtual,
    required bool mostrarFeedback,
  }) async {
    final palpaaLimpo = palpaa.trim();
    final palpbbLimpo = palpbb.trim();

    if (palpaaLimpo.isEmpty || palpbbLimpo.isEmpty) return;
    if (_salvandoPalpite[idjogo] == true) return;

    final palpiteAtualA = palpiteAtual?['palpaa']?.toString();
    final palpiteAtualB = palpiteAtual?['palpbb']?.toString();
    if (palpiteAtualA == palpaaLimpo && palpiteAtualB == palpbbLimpo) return;

    if (!UserSession.canMakePalpite() && palpiteAtual == null) {
      if (mostrarFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Limite de palpites atingido'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
      return;
    }

    final jaTinhaPalpite = palpiteAtual != null;
    setState(() => _salvandoPalpite[idjogo] = true);

    final sucesso = await ApiService.salvarPalpite(
      idjogo: idjogo.toString(),
      palpaa: palpaaLimpo,
      palpbb: palpbbLimpo,
    );

    if (!mounted) return;
    setState(() => _salvandoPalpite[idjogo] = false);

    if (sucesso) {
      setState(() {
        _palpitesLocais[idjogo] = {
          'palpaa': palpaaLimpo,
          'palpbb': palpbbLimpo,
        };
        if (!jaTinhaPalpite) {
          UserSession.palpitesFeitos++;
        }
      });

      _marcarPalpiteSalvoAgora(idjogo);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _rolarParaProximoPalpite(idjogo);
      });

      if (mostrarFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Palpite salvo!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text('Erro ao salvar palpite'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _agendarAutoSave({
    required int idjogo,
    required Map<String, dynamic> jogo,
    required TextEditingController gol1Controller,
    required TextEditingController gol2Controller,
  }) {
    _autoSaveTimers[idjogo]?.cancel();

    _autoSaveTimers[idjogo] = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      if (_salvandoPalpite[idjogo] == true) {
        _agendarAutoSave(
          idjogo: idjogo,
          jogo: jogo,
          gol1Controller: gol1Controller,
          gol2Controller: gol2Controller,
        );
        return;
      }

      final palpaa = gol1Controller.text;
      final palpbb = gol2Controller.text;
      if (palpaa.trim().isEmpty || palpbb.trim().isEmpty) return;

      final palpiteServidor = jogo['usupla'] != null && jogo['usuplb'] != null
          ? {
              'palpaa': jogo['usupla'],
              'palpbb': jogo['usuplb'],
            }
          : null;

      final palpiteAtual = _palpitesLocais[idjogo] ?? palpiteServidor;

      await _salvarPalpiteDoJogo(
        idjogo: idjogo,
        palpaa: palpaa,
        palpbb: palpbb,
        palpiteAtual: palpiteAtual,
        mostrarFeedback: false,
      );
    });
  }

  int calcularPontosGanhos(Map<String, dynamic> jogo) {
    final plcraa = int.tryParse(jogo['plcraa']?.toString() ?? '');
    final plcrbb = int.tryParse(jogo['plcrbb']?.toString() ?? '');
    final usupla = int.tryParse(jogo['usupla']?.toString() ?? '');
    final usuplb = int.tryParse(jogo['usuplb']?.toString() ?? '');

    if (plcraa == null || plcrbb == null || usupla == null || usuplb == null) {
      return 0;
    }

    if (plcraa == usupla && plcrbb == usuplb) {
      return 20;
    }

    if ((plcraa < plcrbb && usupla < usuplb) || (plcraa > plcrbb && usupla > usuplb) || (plcraa == plcrbb && usupla == usuplb)) {
      return 10;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.shade50,
                    Colors.amber.shade100,
                    Colors.amber.shade200,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.amber.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 18,
                    color: Colors.amber.shade900,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Palpites: ${UserSession.palpitesFeitos}/${UserSession.maxPalpites ?? 0}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_jogos.length} jogos',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: _jogos.isEmpty && !_loading
                    ? ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + 92),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),

                          Center(
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 360),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.05),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.sports_soccer_rounded,
                                      size: 38,
                                      color: Color(0xFFCC0000),
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  const Text(
                                    'Nenhum jogo encontrado',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF222222),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    'Ainda não há jogos disponíveis para exibir. Puxe a tela para baixo e tente atualizar.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.keyboard_double_arrow_down_rounded,
                                          size: 18,
                                          color: Color(0xFFCC0000),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Puxe para atualizar',
                                          style: TextStyle(
                                            color: Color(0xFFCC0000),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0 + 92),
                        itemCount: _jogos.length,
                        itemBuilder: (ctx, i) {
                          final jogo = _jogos[i];
                          final fase = jogo['fase'];
                          final idjogo = int.tryParse('${jogo['idjogo']}') ?? 0;
                          final datjog = jogo['datjog'] ?? '';
                          final timeaa = jogo['timeaa'] ?? '';
                          final siglaa = jogo['siglaa'] ?? '';
                          final timebb = jogo['timebb'] ?? '';
                          final siglbb = jogo['siglbb'] ?? '';
                          final plcraa = jogo['plcraa'];
                          final plcrbb = jogo['plcrbb'];
                          final usupla = jogo['usupla'];
                          final usuplb = jogo['usuplb'];

                          final podeEditar = _podeEditarPalpite(datjog);
                          final ehBrasil = _ehJogoDoBrasil(jogo);

                          final palpiteLocal = _palpitesLocais[idjogo];
                          final palpiteServidor = usupla != null && usuplb != null
                              ? {
                                  'palpaa': usupla,
                                  'palpbb': usuplb,
                                }
                              : null;

                          final palpiteAtual = palpiteLocal ?? palpiteServidor;

                          final temPlacarOficial = _placarDefinido(plcraa) && _placarDefinido(plcrbb);
                          final jogoFinalizado = !podeEditar && temPlacarOficial;
                          final salvandoEsteJogo = _salvandoPalpite[idjogo] == true;
                          final salvoRecentemente = _salvoAgoraPorJogo.containsKey(idjogo);
                          final podeSalvarOuEditar = UserSession.canMakePalpite() || palpiteAtual != null;

                          final pontosGanhos = calcularPontosGanhos(jogo);

                          final gol1Controller = _obterControllerGol(
                            idjogo: idjogo,
                            primeiroGol: true,
                            valorInicial: palpiteAtual == null ? '' : '${palpiteAtual['palpaa']}',
                          );
                          final gol2Controller = _obterControllerGol(
                            idjogo: idjogo,
                            primeiroGol: false,
                            valorInicial: palpiteAtual == null ? '' : '${palpiteAtual['palpbb']}',
                          );
                          final gol1FocusNode = _obterFocusNodeGol(idjogo: idjogo, primeiroGol: true);
                          final gol2FocusNode = _obterFocusNodeGol(idjogo: idjogo, primeiroGol: false);

                          return Container(
                            key: _obterCardKey(idjogo),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: ehBrasil ? Colors.green.shade200 : Colors.grey.shade200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: ehBrasil
                                            ? [
                                                Color(0xFFF1FAF4),
                                                Color(0xFFD9F2E2),
                                                Color(0xFFBFE8CA),
                                              ]
                                            : [
                                                Colors.grey.shade50,
                                                Colors.grey.shade100,
                                                Colors.white,
                                              ],
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: ehBrasil ? Colors.green.shade100 : Colors.grey.shade200,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.sports_soccer,
                                            size: 16,
                                            color: ehBrasil ? Colors.green.shade800 : Colors.grey.shade700,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: Text(
                                            '#$idjogo - $fase',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: ehBrasil ? Colors.green.shade900 : Colors.grey.shade800,
                                            ),
                                          ),
                                        ),

                                        if (ehBrasil) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF009739),
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.star_rounded, size: 12, color: Colors.white),
                                                SizedBox(width: 3),
                                                Text(
                                                  '2X',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],

                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.schedule_rounded, size: 12, color: Colors.grey.shade600),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatarData(datjog),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: Colors.grey.shade50,
                                                      shape: BoxShape.rectangle,
                                                      border: Border.all(color: Colors.grey.shade200),
                                                    ),
                                                    child: _getBandeira(siglaa),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    timeaa,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 12,
                                                      color: Colors.black87,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 10),
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Column(
                                                children: [
                                                  if (jogoFinalizado) ...[
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade900,
                                                        borderRadius: BorderRadius.circular(14),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withValues(alpha: 0.12),
                                                            blurRadius: 10,
                                                            offset: const Offset(0, 4),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        '$plcraa X $plcrbb',
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.w900,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  if (!jogoFinalizado && podeEditar && podeSalvarOuEditar)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade50,
                                                        borderRadius: BorderRadius.circular(16),
                                                        border: Border.all(color: Colors.grey.shade200),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 50,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(12),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.grey.shade300,
                                                                  blurRadius: 6,
                                                                  offset: const Offset(0, 2),
                                                                ),
                                                              ],
                                                            ),
                                                            child: TextField(
                                                              controller: gol1Controller,
                                                              focusNode: gol1FocusNode,
                                                              onChanged: (_) => _agendarAutoSave(
                                                                idjogo: idjogo,
                                                                jogo: jogo,
                                                                gol1Controller: gol1Controller,
                                                                gol2Controller: gol2Controller,
                                                              ),
                                                              onSubmitted: (_) => gol2FocusNode.requestFocus(),
                                                              textInputAction: TextInputAction.next,
                                                              textAlign: TextAlign.center,
                                                              keyboardType: TextInputType.number,
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter.digitsOnly,
                                                                LengthLimitingTextInputFormatter(2),
                                                              ],
                                                              style: const TextStyle(
                                                                fontSize: 22,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color(0xFFCC0000),
                                                              ),
                                                              decoration: InputDecoration(
                                                                filled: true,
                                                                fillColor: Colors.white,
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(12),
                                                                  borderSide: BorderSide.none,
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(12),
                                                                  borderSide: const BorderSide(color: Color(0xFFCC0000), width: 2),
                                                                ),
                                                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                                              ),
                                                            ),
                                                          ),

                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                                            child: Text(
                                                              'X',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.w900,
                                                                color: Colors.grey.shade600,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 50,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(12),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.grey.shade300,
                                                                  blurRadius: 6,
                                                                  offset: const Offset(0, 2),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Focus(
                                                              onKeyEvent: (_, event) {
                                                                if (event is! KeyDownEvent) {
                                                                  return KeyEventResult.ignored;
                                                                }
                                                                if (event.logicalKey != LogicalKeyboardKey.tab) {
                                                                  return KeyEventResult.ignored;
                                                                }
                                                                if (HardwareKeyboard.instance.isShiftPressed) {
                                                                  return KeyEventResult.ignored;
                                                                }

                                                                _irParaProximoJogoComTab(
                                                                  idjogoAtual: idjogo,
                                                                  gol1Controller: gol1Controller,
                                                                  gol2Controller: gol2Controller,
                                                                  palpiteAtual: palpiteAtual,
                                                                );
                                                                return KeyEventResult.handled;
                                                              },
                                                              child: TextField(
                                                                controller: gol2Controller,
                                                                focusNode: gol2FocusNode,
                                                                onChanged: (_) => _agendarAutoSave(
                                                                  idjogo: idjogo,
                                                                  jogo: jogo,
                                                                  gol1Controller: gol1Controller,
                                                                  gol2Controller: gol2Controller,
                                                                ),
                                                                onSubmitted: (_) => _irParaProximoJogoComTab(
                                                                  idjogoAtual: idjogo,
                                                                  gol1Controller: gol1Controller,
                                                                  gol2Controller: gol2Controller,
                                                                  palpiteAtual: palpiteAtual,
                                                                ),
                                                                textInputAction: TextInputAction.next,
                                                                textAlign: TextAlign.center,
                                                                keyboardType: TextInputType.number,
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter.digitsOnly,
                                                                  LengthLimitingTextInputFormatter(2),
                                                                ],
                                                                style: const TextStyle(
                                                                  fontSize: 22,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Color(0xFFCC0000),
                                                                ),
                                                                decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    borderSide: BorderSide.none,
                                                                  ),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    borderSide: const BorderSide(color: Color(0xFFCC0000), width: 2),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  if (!jogoFinalizado && podeEditar && !podeSalvarOuEditar)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade100,
                                                        borderRadius: BorderRadius.circular(14),
                                                        border: Border.all(color: Colors.grey.shade300),
                                                      ),
                                                      child: Text(
                                                        '- X -',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w900,
                                                          color: Colors.grey.shade500,
                                                        ),
                                                      ),
                                                    ),

                                                  if (!jogoFinalizado && !podeEditar && palpiteAtual != null)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                                      decoration: BoxDecoration(
                                                        gradient: const LinearGradient(
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                          colors: [
                                                            Color(0xFFCC0000),
                                                            Color(0xFF990000),
                                                          ],
                                                        ),
                                                        borderRadius: BorderRadius.circular(14),
                                                      ),
                                                      child: Text(
                                                        '${palpiteAtual['palpaa']} X ${palpiteAtual['palpbb']}',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w900,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),

                                                  if (!jogoFinalizado && !podeEditar && palpiteAtual == null)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade100,
                                                        borderRadius: BorderRadius.circular(14),
                                                        border: Border.all(color: Colors.grey.shade300),
                                                      ),
                                                      child: Text(
                                                        '- X -',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w900,
                                                          color: Colors.grey.shade500,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),

                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: Colors.grey.shade50,
                                                      shape: BoxShape.rectangle,
                                                      border: Border.all(color: Colors.grey.shade200),
                                                    ),
                                                    child: _getBandeira(siglbb),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    timebb,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 12,
                                                      color: Colors.black87,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 16),

                                        if (jogoFinalizado) ...[
                                          Wrap(
                                            alignment: WrapAlignment.center,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: 10,
                                            runSpacing: 8,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF7F7F8),
                                                  borderRadius: BorderRadius.circular(999),
                                                  border: Border.all(
                                                    color: const Color(0xFFE3E4E8),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.04),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.edit_note_rounded,
                                                      size: 16,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Meu palpite: ${gol1Controller.text} X ${gol2Controller.text}',
                                                      style: TextStyle(
                                                        fontSize: 13.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.grey.shade800,
                                                        letterSpacing: 0.1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.amber.shade50,
                                                      Colors.orange.shade50,
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(999),
                                                  border: Border.all(
                                                    color: Colors.amber.shade200,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.orange.withValues(alpha: 0.08),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: Colors.amber.shade100,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.emoji_events_rounded,
                                                        size: 13,
                                                        color: Colors.amber.shade800,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '$pontosGanhos pts ganhos',
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        fontWeight: FontWeight.w800,
                                                        color: Colors.orange.shade900,
                                                        letterSpacing: 0.1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withAlpha(26),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey.withAlpha(77)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.check_circle, color: Colors.grey, size: 18),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    'Jogo finalizado',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ] else if (!podeEditar)
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withAlpha(26),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.orange.withAlpha(77)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.timer_off, color: Colors.orange, size: 18),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    'Palpites bloqueados, aguarde \naté ser cadastro o placar final',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.orange,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else if (!UserSession.canMakePalpite() && palpiteAtual == null)
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withAlpha(26),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.red.withAlpha(77)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.block, color: Colors.red, size: 18),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    'Limite de palpites atingido ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          SizedBox(
                                            height: 44,
                                            child: AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 220),
                                              switchInCurve: Curves.easeOut,
                                              switchOutCurve: Curves.easeIn,
                                              child: salvandoEsteJogo
                                                  ? KeyedSubtree(
                                                      key: ValueKey('salvando-$idjogo'),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blue.withAlpha(26),
                                                          borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(color: Colors.blue.withAlpha(77)),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.sync_rounded, color: Colors.blue, size: 16),
                                                            const SizedBox(width: 8),
                                                            Flexible(
                                                              child: Text(
                                                                'Salvando...',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Colors.blue,
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 11.5,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : salvoRecentemente
                                                  ? KeyedSubtree(
                                                      key: ValueKey('salvo-$idjogo'),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green.withAlpha(26),
                                                          borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(color: Colors.green.withAlpha(77)),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                                                            const SizedBox(width: 8),
                                                            Flexible(
                                                              child: Text(
                                                                'Palpite salvo automaticamente',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Colors.green,
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 11.5,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : KeyedSubtree(
                                                      key: ValueKey('pronto-$idjogo'),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blue.withAlpha(26),
                                                          borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(color: Colors.blue.withAlpha(77)),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.auto_awesome_rounded, color: Colors.blue, size: 16),
                                                            const SizedBox(width: 8),
                                                            Flexible(
                                                              child: Text(
                                                                'Preencha os dois placares para salvar.',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Colors.blue,
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 11.5,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
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
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),

        if (_loading)
          Container(
            color: Colors.black.withValues(alpha: 0.55),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.92, end: 1),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.28),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 54,
                            height: 54,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              color: const Color(0xFFCC0000),
                              backgroundColor: Colors.red.shade50,
                            ),
                          ),
                          const Icon(
                            Icons.sports_soccer,
                            size: 24,
                            color: Color(0xFFCC0000),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Carregando jogos...',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Aguarde um momento',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
