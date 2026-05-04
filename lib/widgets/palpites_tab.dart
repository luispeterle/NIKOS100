import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Map<int, Map<String, dynamic>> _palpitesLocais = {}; // Armazena palpites já feitos localmente

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final jogos = await ApiService.getJogos();

    setState(() {
      _jogos = jogos;
      _loading = false;
    });
  }

  // Converte sigla para código de bandeira
  String _getSiglaParaBandeira(String sigla) {
    final Map<String, String> siglaParaCodigo = {
      'QAT': 'qa', 'ECU': 'ec', 'ENG': 'gb-eng', 'IRN': 'ir',
      'ARG': 'ar', 'KSA': 'sa', 'GER': 'de', 'JPN': 'jp',
      'BRA': 'br', 'SRB': 'rs', 'POR': 'pt', 'GHA': 'gh',
      'FRA': 'fr', 'DEN': 'dk', 'ESP': 'es', 'CRO': 'hr',
      'NED': 'nl', 'USA': 'us', 'MAR': 'ma', 'BEL': 'be',
      'MEX': 'mx', 'CAN': 'ca', 'ITA': 'it', 'URU': 'uy',
      'COL': 'co', 'CHI': 'cl', 'PER': 'pe', 'KOR': 'kr',
      'AUS': 'au', 'NZL': 'nz', 'NGA': 'ng', 'SEN': 'sn',
      'UAE': 'ae', 'POL': 'pl', 'SUI': 'ch', 'SWE': 'se',
      'NOR': 'no', 'FIN': 'fi', 'ISL': 'is', 'TUR': 'tr',
      'GRE': 'gr', 'CZE': 'cz', 'HUN': 'hu', 'SCO': 'gb-sct',
      'IRL': 'ie', 'WAL': 'gb-wls', 'UKR': 'ua', 'CRC': 'cr',
      // Adicionar outras seleções conforme necessário.
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
    final dataJogo = _parseDataJogo(datjog);
    if (dataJogo == null) return false;

    final hoje = DateTime.now();
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    final dataJogoSemHora = DateTime(dataJogo.year, dataJogo.month, dataJogo.day);

    return dataJogoSemHora.isAfter(hojeSemHora);
  }

  // Formata data para exibição
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

  DateTime? _parseDataJogo(String datjog) {
    try {
      final normalizada = datjog.trim().replaceFirst('T', ' ');
      final partes = normalizada.split(' ');
      if (partes.length < 2) return null;

      final dataPartes = partes[0].split('-');
      final horaPartes = partes[1].split(':');
      if (dataPartes.length != 3 || horaPartes.length < 2) return null;

      return DateTime(
        int.parse(dataPartes[0]),
        int.parse(dataPartes[1]),
        int.parse(dataPartes[2]),
        int.parse(horaPartes[0]),
        int.parse(horaPartes[1]),
      );
    } catch (e) {
      return null;
    }
  }

  // Verifica se é jogo do Brasil (pontos em dobro)
  bool _ehJogoDoBrasil(Map<String, dynamic> jogo) {
    final siglaa = (jogo['siglaa'] ?? '').toString().toUpperCase();
    final siglbb = (jogo['siglbb'] ?? '').toString().toUpperCase();
    return siglaa == 'BRA' || siglbb == 'BRA';
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavSpace = 92.0 + MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        Column(
          children: [
            // Info de palpites restantes
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

            // Lista de jogos
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: _jogos.isEmpty && !_loading
                    ? ListView(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomNavSpace),
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
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomNavSpace),
                        itemCount: _jogos.length,
                        itemBuilder: (ctx, i) => _buildJogoCard(_jogos[i]),
                      ),
              ),
            ),
          ],
        ),

        // Loading
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

  Widget _buildJogoCard(Map<String, dynamic> jogo) {
    final idjogo = jogo['idjogo'];
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

    // Prioriza o palpite local recem-salvo para evitar "voltar" ao valor antigo do servidor antes da proxima atualizacao da lista.
    final palpiteAtual = palpiteLocal ?? palpiteServidor;

    final temPlacarOficial = plcraa != null && plcrbb != null && (plcraa != 0 || plcrbb != 0);
    final jogoFinalizado = !podeEditar && temPlacarOficial;

    final gol1Controller = TextEditingController(text: palpiteAtual == null ? '' : '${palpiteAtual['palpaa']}');
    final gol2Controller = TextEditingController(text: palpiteAtual == null ? '' : '${palpiteAtual['palpbb']}');

    return Container(
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
                      'Jogo #$idjogo',
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
                            if (jogoFinalizado)
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

                            if (!jogoFinalizado && podeEditar)
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
                                    _buildScoreInput(gol1Controller),
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
                                    _buildScoreInput(gol2Controller),
                                  ],
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

                  if (jogoFinalizado)
                    _buildStatusContainer(
                      icon: Icons.check_circle,
                      text: 'Jogo finalizado',
                      color: Colors.grey,
                    )
                  else if (!podeEditar)
                    _buildStatusContainer(
                      icon: Icons.timer_off,
                      text: 'Palpites bloqueados',
                      color: Colors.orange,
                    )
                  else if (!UserSession.canMakePalpite() && palpiteAtual == null)
                    _buildStatusContainer(
                      icon: Icons.block,
                      text: 'Limite de palpites atingido ',
                      color: Colors.red,
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final palpaa = gol1Controller.text;
                          final palpbb = gol2Controller.text;

                          if (palpaa.isEmpty || palpbb.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Preencha o placar dos dois times'),
                                backgroundColor: Colors.orange.shade600,
                              ),
                            );
                            return;
                          }

                          setState(() => _loading = true);

                          final sucesso = await ApiService.salvarPalpite(
                            idjogo: idjogo.toString(),
                            palpaa: palpaa,
                            palpbb: palpbb,
                          );

                          setState(() => _loading = false);
                          if (!mounted) return;

                          if (sucesso) {
                            setState(() {
                              _palpitesLocais[idjogo] = {
                                'palpaa': palpaa,
                                'palpbb': palpbb,
                              };
                            });

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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCC0000),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              palpiteAtual != null ? Icons.edit_rounded : Icons.save_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              palpiteAtual != null ? 'EDITAR PALPITE' : 'SALVAR PALPITE',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                fontSize: 13,
                              ),
                            ),
                          ],
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
  }

  Widget _buildScoreInput(TextEditingController controller) {
    return Container(
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
        controller: controller,
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
    );
  }

  Widget _buildStatusContainer({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
