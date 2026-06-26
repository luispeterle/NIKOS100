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
  final Map<int, Timer> _navegacaoInativaTimers = {};
  final Map<int, Timer> _salvoAgoraTimers = {};
  final Map<int, DateTime> _salvoAgoraPorJogo = {};
  final Map<int, TextEditingController> _gol1Controllers = {};
  final Map<int, TextEditingController> _gol2Controllers = {};
  final Map<int, FocusNode> _gol1FocusNodes = {};
  final Map<int, FocusNode> _gol2FocusNodes = {};
  final Map<int, bool> _jogosComInteracao = {};
  final Map<int, bool> _salvandoPalpite = {};
  final Map<int, GlobalKey> _jogoCardKeys = {};
  Timer? _renderAbertosTimer;
  Timer? _renderFinalizadosTimer;
  bool _loading = true;
  static const Duration _tempoInatividadeNavegacao = Duration(seconds: 2);

  bool _mostrarJogosAbertos = true;
  bool _mostrarJogosFinalizados = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _renderAbertosTimer?.cancel();
    _renderFinalizadosTimer?.cancel();
    for (final timer in _autoSaveTimers.values) {
      timer.cancel();
    }
    for (final timer in _navegacaoInativaTimers.values) {
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

    return _podeSalvarNoJogo(
      idjogo: idjogo,
      palpiteAtual: palpiteAtual,
    );
  }

  int _idJogo(Map<String, dynamic> jogo) => int.tryParse('${jogo['idjogo']}') ?? 0;

  DateTime? _dataHoraJogo(Map<String, dynamic> jogo) {
    final datjog = (jogo['datjog'] ?? '').toString();
    return tryParseDatjog(datjog);
  }

  int _compararJogosPorDataHora(Map<String, dynamic> a, Map<String, dynamic> b) {
    final dataA = _dataHoraJogo(a);
    final dataB = _dataHoraJogo(b);

    if (dataA != null && dataB != null) {
      final comparacaoData = dataA.compareTo(dataB);
      if (comparacaoData != 0) return comparacaoData;
    } else if (dataA != null) {
      return -1;
    } else if (dataB != null) {
      return 1;
    }

    return _idJogo(a).compareTo(_idJogo(b));
  }

  List<Map<String, dynamic>> _ordenarJogosPorDataHora(Iterable<Map<String, dynamic>> jogos) {
    return jogos.toList()..sort(_compararJogosPorDataHora);
  }

  int? _obterProximoJogoElegivelId(int idjogoAtual) {
    final jogosOrdenados = _ordenarJogosPorDataHora(_jogos.where((jogo) => !_jogoEstaFinalizado(jogo)));
    final indiceAtual = jogosOrdenados.indexWhere((jogo) => _idJogo(jogo) == idjogoAtual);

    for (var index = indiceAtual + 1; index < jogosOrdenados.length; index++) {
      final jogo = jogosOrdenados[index];

      if (_jogoPodeReceberPalpite(jogo)) {
        return _idJogo(jogo);
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
    _navegacaoInativaTimers[idjogoAtual]?.cancel();

    await _salvarPalpiteDoJogo(
      idjogo: idjogoAtual,
      palpaa: gol1Controller.text,
      palpbb: gol2Controller.text,
      palpiteAtual: palpiteAtual,
      mostrarFeedback: false,
      rolarAposSalvar: false,
    );

    if (!mounted) return;

    final idProximoJogo = _obterProximoJogoElegivelId(idjogoAtual);
    if (idProximoJogo == null) return;

    final ambosPreenchidos = gol1Controller.text.trim().isNotEmpty && gol2Controller.text.trim().isNotEmpty;
    if (ambosPreenchidos) {
      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;
    }

    await _rolarParaProximoPalpite(idjogoAtual);
    if (!mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    _focarCampoComSelecao(
      focusNode: _obterFocusNodeGol(idjogo: idProximoJogo, primeiroGol: true),
      controller: _obterControllerGol(
        idjogo: idProximoJogo,
        primeiroGol: true,
        valorInicial: '',
      ),
    );
  }

  Map<String, dynamic>? _obterPalpiteAtualDoJogo({
    required int idjogo,
    required Map<String, dynamic> jogo,
  }) {
    final palpiteServidor = jogo['usupla'] != null && jogo['usuplb'] != null
        ? {
            'palpaa': jogo['usupla'],
            'palpbb': jogo['usuplb'],
          }
        : null;

    return _palpitesLocais[idjogo] ?? palpiteServidor;
  }

  void _selecionarTextoInteiro({
    required FocusNode focusNode,
    required TextEditingController controller,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !focusNode.hasFocus) return;
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
    });
  }

  void _focarCampoComSelecao({
    required FocusNode focusNode,
    required TextEditingController controller,
  }) {
    if (!mounted) return;
    focusNode.requestFocus();
    _selecionarTextoInteiro(
      focusNode: focusNode,
      controller: controller,
    );
  }

  void _focarNoGol2EAguardarInatividade({
    required int idjogo,
    required Map<String, dynamic> jogo,
    required TextEditingController gol1Controller,
    required TextEditingController gol2Controller,
  }) {
    if (!mounted) return;
    _focarCampoComSelecao(
      focusNode: _obterFocusNodeGol(idjogo: idjogo, primeiroGol: false),
      controller: gol2Controller,
    );

    _agendarNavegacaoPorInatividade(
      idjogo: idjogo,
      jogo: jogo,
      primeiroGol: false,
      gol1Controller: gol1Controller,
      gol2Controller: gol2Controller,
    );
  }

  void _agendarNavegacaoPorInatividade({
    required int idjogo,
    required Map<String, dynamic> jogo,
    required bool primeiroGol,
    required TextEditingController gol1Controller,
    required TextEditingController gol2Controller,
  }) {
    _navegacaoInativaTimers[idjogo]?.cancel();

    _navegacaoInativaTimers[idjogo] = Timer(_tempoInatividadeNavegacao, () async {
      if (!mounted) return;
      if (_jogosComInteracao[idjogo] != true) return;

      final focusNodeEsperado = _obterFocusNodeGol(idjogo: idjogo, primeiroGol: primeiroGol);
      if (!focusNodeEsperado.hasFocus) return;

      if (_salvandoPalpite[idjogo] == true) {
        _agendarNavegacaoPorInatividade(
          idjogo: idjogo,
          jogo: jogo,
          primeiroGol: primeiroGol,
          gol1Controller: gol1Controller,
          gol2Controller: gol2Controller,
        );
        return;
      }

      if (primeiroGol) {
        _focarNoGol2EAguardarInatividade(
          idjogo: idjogo,
          jogo: jogo,
          gol1Controller: gol1Controller,
          gol2Controller: gol2Controller,
        );
        return;
      }

      await _irParaProximoJogoComTab(
        idjogoAtual: idjogo,
        gol1Controller: gol1Controller,
        gol2Controller: gol2Controller,
        palpiteAtual: _obterPalpiteAtualDoJogo(idjogo: idjogo, jogo: jogo),
      );
    });
  }

  void _registrarInteracaoNoCampo({
    required int idjogo,
    required Map<String, dynamic> jogo,
    required bool primeiroGol,
    required TextEditingController gol1Controller,
    required TextEditingController gol2Controller,
  }) {
    _jogosComInteracao[idjogo] = true;

    _agendarAutoSave(
      idjogo: idjogo,
      jogo: jogo,
      gol1Controller: gol1Controller,
      gol2Controller: gol2Controller,
    );

    _agendarNavegacaoPorInatividade(
      idjogo: idjogo,
      jogo: jogo,
      primeiroGol: primeiroGol,
      gol1Controller: gol1Controller,
      gol2Controller: gol2Controller,
    );
  }

  void _registrarFocoNoCampo({
    required int idjogo,
  }) {
    // Apenas foco/clique não deve acionar navegação automática.
    // A navegação por inatividade começa somente após digitação (onChanged).
    _navegacaoInativaTimers[idjogo]?.cancel();
  }

  Future<void> _salvarPalpiteDoJogo({
    required int idjogo,
    required String palpaa,
    required String palpbb,
    required Map<String, dynamic>? palpiteAtual,
    required bool mostrarFeedback,
    bool rolarAposSalvar = false,
  }) async {
    final palpaaLimpo = palpaa.trim();
    final palpbbLimpo = palpbb.trim();

    if (palpaaLimpo.isEmpty || palpbbLimpo.isEmpty) return;
    if (_salvandoPalpite[idjogo] == true) return;

    final palpiteAtualA = palpiteAtual?['palpaa']?.toString();
    final palpiteAtualB = palpiteAtual?['palpbb']?.toString();
    if (palpiteAtualA == palpaaLimpo && palpiteAtualB == palpbbLimpo) return;

    if (!_podeSalvarNoJogo(idjogo: idjogo, palpiteAtual: palpiteAtual)) {
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
      if (rolarAposSalvar) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          await Future<void>.delayed(const Duration(milliseconds: 320));
          if (!mounted) return;
          await _rolarParaProximoPalpite(idjogo);
        });
      }

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
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          elevation: 8,
          duration: const Duration(seconds: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Palpite não salvo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      'O jogo pode já ter começado. Se achar que houve erro, entre em contato.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
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
        rolarAposSalvar: false,
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
      if (jogo['siglaa'] == 'BRA' || jogo['siglbb'] == 'BRA') {
        return 60;
      }
      return 30;
    }

    if ((plcraa < plcrbb && usupla < usuplb) || (plcraa > plcrbb && usupla > usuplb) || (plcraa == plcrbb && usupla == usuplb)) {
      if (jogo['siglaa'] == 'BRA' || jogo['siglbb'] == 'BRA') {
        return 20;
      }
      return 10;
    }

    return 0;
  }

  bool _jogoEstaFinalizado(Map<String, dynamic> jogo) {
    final datjog = (jogo['datjog'] ?? '').toString();
    final podeEditar = _podeEditarPalpite(datjog);

    final temPlacarOficial = _placarDefinido(jogo['plcraa']) && _placarDefinido(jogo['plcrbb']);

    return !podeEditar && temPlacarOficial;
  }

  bool _isJogoExcecaoLimite(int idjogo) {
    return idjogo >= 1 && idjogo <= 10;
  }

  bool _podeSalvarNoJogo({
    required int idjogo,
    required Map<String, dynamic>? palpiteAtual,
  }) {
    return _isJogoExcecaoLimite(idjogo) || UserSession.canMakePalpite() || palpiteAtual != null;
  }

  @override
  Widget build(BuildContext context) {
    final jogosAbertos = _jogos.where((jogo) => !_jogoEstaFinalizado(jogo)).toList();
    final jogosFinalizados = _jogos.where((jogo) => _jogoEstaFinalizado(jogo)).toList();
    final jogosAbertosExibidos = _ordenarJogosPorDataHora(jogosAbertos);
    final jogosFinalizadosExibidos = _ordenarJogosPorDataHora(jogosFinalizados);

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
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (UserSession.totalCompra >= 500 || UserSession.maxPalpites == 110) ...[
                            TextSpan(
                              text: 'Todos os jogos ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(
                              text: 'LIBERADOS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0A8F3C),
                              ),
                            ),
                          ] else ...[
                            const TextSpan(
                              text: 'Faltam ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(
                              text: formatMoneyValue((500 - UserSession.totalCompra).toString()),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFB60000),
                              ),
                            ),
                            const TextSpan(
                              text: ' em compras para liberar todos os jogos',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                    : ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  initiallyExpanded: _mostrarJogosAbertos,
                                  onExpansionChanged: (value) {
                                    setState(() => _mostrarJogosAbertos = value);
                                  },
                                  backgroundColor: Colors.white.withValues(alpha: 0.55),
                                  collapsedBackgroundColor: Colors.white.withValues(alpha: 0.55),
                                  iconColor: const Color(0xFF8B5E3C),
                                  collapsedIconColor: const Color(0xFF8B5E3C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide.none,
                                  ),
                                  collapsedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide.none,
                                  ),

                                  tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),

                                  leading: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Icon(
                                      Icons.lock_open_rounded,
                                      color: Colors.green,
                                      size: 21,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Jogos abertos',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF222222),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.10),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '${jogosAbertos.length}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    'Jogos disponíveis ou aguardando placar final',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  children: [
                                    if (jogosAbertos.isEmpty)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Text(
                                          'Nenhum jogo aberto.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),

                                    ...jogosAbertosExibidos.map((jogo) {
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
                                      final podeSalvarOuEditar = _podeSalvarNoJogo(
                                        idjogo: idjogo,
                                        palpiteAtual: palpiteAtual,
                                      );

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
                                              color: Colors.black.withValues(alpha: 0.12),
                                              blurRadius: 24,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 10),
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
                                                        '$fase',
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
                                              if (idjogo > 72)
                                                Container(
                                                  width: double.infinity,
                                                  margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFF8E1),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: const Color(0xFFFFE8A3),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.info_outline_rounded,
                                                        size: 15,
                                                        color: Color(0xFF9A6A00),
                                                      ),
                                                      SizedBox(width: 7),
                                                      Expanded(
                                                        child: Text(
                                                          'Só será considerado o placar em tempo regulamentar!',
                                                          style: TextStyle(
                                                            fontSize: 11.5,
                                                            height: 1.25,
                                                            fontWeight: FontWeight.w600,
                                                            color: Color(0xFF7A5700),
                                                          ),
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
                                                                child: getBandeira(siglaa),
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
                                                                            _focarNoGol2EAguardarInatividade(
                                                                              idjogo: idjogo,
                                                                              jogo: jogo,
                                                                              gol1Controller: gol1Controller,
                                                                              gol2Controller: gol2Controller,
                                                                            );
                                                                            return KeyEventResult.handled;
                                                                          },
                                                                          child: TextField(
                                                                            controller: gol1Controller,
                                                                            focusNode: gol1FocusNode,
                                                                            onTap: () {
                                                                              _selecionarTextoInteiro(
                                                                                focusNode: gol1FocusNode,
                                                                                controller: gol1Controller,
                                                                              );
                                                                              _registrarFocoNoCampo(
                                                                                idjogo: idjogo,
                                                                              );
                                                                            },
                                                                            onChanged: (_) => _registrarInteracaoNoCampo(
                                                                              idjogo: idjogo,
                                                                              jogo: jogo,
                                                                              primeiroGol: true,
                                                                              gol1Controller: gol1Controller,
                                                                              gol2Controller: gol2Controller,
                                                                            ),
                                                                            onSubmitted: (_) => _focarNoGol2EAguardarInatividade(
                                                                              idjogo: idjogo,
                                                                              jogo: jogo,
                                                                              gol1Controller: gol1Controller,
                                                                              gol2Controller: gol2Controller,
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
                                                                              _focarCampoComSelecao(
                                                                                focusNode: gol1FocusNode,
                                                                                controller: gol1Controller,
                                                                              );
                                                                              return KeyEventResult.handled;
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
                                                                            onTap: () {
                                                                              _selecionarTextoInteiro(
                                                                                focusNode: gol2FocusNode,
                                                                                controller: gol2Controller,
                                                                              );
                                                                              _registrarFocoNoCampo(
                                                                                idjogo: idjogo,
                                                                              );
                                                                            },
                                                                            onChanged: (_) => _registrarInteracaoNoCampo(
                                                                              idjogo: idjogo,
                                                                              jogo: jogo,
                                                                              primeiroGol: false,
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
                                                                child: getBandeira(siglbb),
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
                                                                'Palpites bloqueados, aguarde \naté ser cadastrado o placar final',
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
                                                    else if (!podeSalvarOuEditar)
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
                                                              : (gol1Controller.text.isEmpty && gol2Controller.text.isEmpty)
                                                              ? KeyedSubtree(
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
                                                                )
                                                              : KeyedSubtree(
                                                                  key: ValueKey('pronto-$idjogo'),
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.deepOrange.withAlpha(26),
                                                                      borderRadius: BorderRadius.circular(12),
                                                                      border: Border.all(color: Colors.deepOrange.withAlpha(77)),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        Icon(Icons.edit_rounded, color: Colors.deepOrange, size: 16),
                                                                        const SizedBox(width: 8),
                                                                        Flexible(
                                                                          child: Text(
                                                                            'Altere um placar para habilitar o salvamento',
                                                                            textAlign: TextAlign.center,
                                                                            style: TextStyle(
                                                                              color: Colors.deepOrange,
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
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Container(
                            margin: const EdgeInsets.only(bottom: 12),

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  initiallyExpanded: _mostrarJogosFinalizados,
                                  onExpansionChanged: (value) {
                                    setState(() => _mostrarJogosFinalizados = value);
                                  },
                                  backgroundColor: Colors.white.withValues(alpha: 0.55),
                                  collapsedBackgroundColor: Colors.white.withValues(alpha: 0.55),
                                  iconColor: const Color(0xFF8B5E3C),
                                  collapsedIconColor: const Color(0xFF8B5E3C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide.none,
                                  ),
                                  collapsedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide.none,
                                  ),
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                  leading: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.grey,
                                      size: 21,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Jogos finalizados',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF222222),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '${jogosFinalizados.length}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    'Jogos com placar oficial cadastrado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  children: [
                                    if (jogosFinalizados.isEmpty)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Text(
                                          'Nenhum jogo finalizado.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),

                                    ...jogosFinalizadosExibidos.map((jogo) {
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
                                              color: Colors.black.withValues(alpha: 0.12),
                                              blurRadius: 24,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 10),
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
                                                                child: getBandeira(siglaa),
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
                                                                            _focarNoGol2EAguardarInatividade(
                                                                              idjogo: idjogo,
                                                                              jogo: jogo,
                                                                              gol1Controller: gol1Controller,
                                                                              gol2Controller: gol2Controller,
                                                                            );
                                                                            return KeyEventResult.handled;
                                                                          },
                                                                          child: TextField(
                                                                            controller: gol1Controller,
                                                                            focusNode: gol1FocusNode,
                                                                            onTap: () {
                                                                              _selecionarTextoInteiro(
                                                                                focusNode: gol1FocusNode,
                                                                                controller: gol1Controller,
                                                                              );
                                                                              _registrarFocoNoCampo(
                                                                                idjogo: idjogo,
                                                                              );
                                                                            },
                                                                            onChanged: (_) => _registrarInteracaoNoCampo(
                                                                              idjogo: idjogo,
                                                                              jogo: jogo,
                                                                              primeiroGol: true,
                                                                              gol1Controller: gol1Controller,
                                                                              gol2Controller: gol2Controller,
                                                                            ),
                                                                            onSubmitted: (_) => _focarNoGol2EAguardarInatividade(
                                                                              idjogo: idjogo,
                                                                              jogo: jogo,
                                                                              gol1Controller: gol1Controller,
                                                                              gol2Controller: gol2Controller,
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
                                                                              _focarCampoComSelecao(
                                                                                focusNode: gol1FocusNode,
                                                                                controller: gol1Controller,
                                                                              );
                                                                              return KeyEventResult.handled;
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
                                                                            onTap: () {
                                                                              _selecionarTextoInteiro(
                                                                                focusNode: gol2FocusNode,
                                                                                controller: gol2Controller,
                                                                              );
                                                                              _registrarFocoNoCampo(
                                                                                idjogo: idjogo,
                                                                              );
                                                                            },
                                                                            onChanged: (_) => _registrarInteracaoNoCampo(
                                                                              idjogo: idjogo,
                                                                              jogo: jogo,
                                                                              primeiroGol: false,
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
                                                                child: getBandeira(siglbb),
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
                                                                'Palpites bloqueados, aguarde \naté ser cadastrado o placar final',
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
                                                    else if (!podeSalvarOuEditar)
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
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
