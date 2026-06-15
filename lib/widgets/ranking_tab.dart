import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nikos/services/user_session.dart';
import 'package:nikos/utils/date_utils.dart';
import '../services/api_service.dart';

class RankingTab extends StatefulWidget {
  final Map<String, dynamic> user;

  const RankingTab({super.key, required this.user});

  @override
  State<RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends State<RankingTab> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _ranking = [];
  List<Map<String, dynamic>> _parcipantesCount = [];
  Map<String, dynamic>? meuRanking;

  DateTime? _lastUpdate;
  bool _loading = true;
  Timer? _autoRefreshTimer;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadRanking();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();

    _animController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!mounted || _loading) return;
      _loadRanking();
    });
  }

  Future<void> _loadRanking() async {
    setState(() => _loading = true);

    final ranking = await ApiService.getRanking();
    final parcipantesCount = await ApiService.getCountParticipante();
    if (!mounted) return;
    final userRanking = _getUserRanking(ranking);
    setState(() {
      _parcipantesCount = parcipantesCount;
      _ranking = ranking;
      meuRanking = userRanking;
      _lastUpdate = DateTime.now();
      _loading = false;
    });

    _animController.forward(from: 0);
  }

  Map<String, dynamic>? _getUserRanking(List<Map<String, dynamic>> rankingList) {
    final cpf = UserSession.cgccpf;
    if (cpf == null) return null;

    String onlyCpf(v) => v.toString().replaceAll(RegExp(r'[^0-9]'), '').padLeft(11, '0');

    final normalizedCpf = onlyCpf(cpf);

    for (final item in rankingList) {
      final itemCpf = item['cpfcli'];
      if (itemCpf == null) continue;

      if (onlyCpf(itemCpf) == normalizedCpf) {
        return item;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final top20Count = _ranking.length > 20 ? 20 : _ranking.length;

    return RefreshIndicator(
      onRefresh: _loadRanking,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFCC0000),
                      Color(0xFF9F0000),
                      Color(0xFF730000),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFFCC0000).withValues(alpha: 0.20),
                      blurRadius: 24,
                      spreadRadius: -6,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: 14,
                      top: 16,
                      child: Icon(
                        Icons.emoji_events_rounded,
                        size: 105,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),

                    Positioned(
                      left: -36,
                      bottom: -38,
                      child: Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 18,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.20),
                              ),
                            ),
                            child: Text(
                              'RANKING DO BOLÃO ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                letterSpacing: 1.6,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Disputa valendo!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Acompanhe a classificação dos participantes em tempo real.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.90),
                              fontSize: 13,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 22),

                          Container(
                            constraints: const BoxConstraints(maxWidth: 430),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3F3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 16,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCC0000).withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.groups_2_rounded,
                                    color: Color(0xFFCC0000),
                                    size: 25,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${_parcipantesCount.isNotEmpty ? _parcipantesCount[0]['totalParticipantes'] ?? 0 : 0} participantes',
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFFB00000),
                                          fontSize: 20,
                                          height: 1.05,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'concorrendo no ranking',
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
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
                  borderRadius: BorderRadius.circular(16),
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
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.shade200,
                        ),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: Colors.amber.shade800,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Atualização automática',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'A cada 5 min. Última: ${_lastUpdate != null ? "${_lastUpdate!.hour.toString().padLeft(2, '0')}:${_lastUpdate!.minute.toString().padLeft(2, '0')}" : "-"}',
                            style: TextStyle(
                              color: Colors.amber.shade800,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _loading ? null : _loadRanking,
                      borderRadius: BorderRadius.circular(999),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _loading ? Colors.white.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.amber.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _loading
                                ? SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.amber.shade800,
                                    ),
                                  )
                                : Icon(
                                    Icons.refresh_rounded,
                                    size: 16,
                                    color: Colors.amber.shade900,
                                  ),
                            const SizedBox(width: 6),
                            Text(
                              _loading ? 'Atualizando' : 'Atualizar',
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (meuRanking != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                child: Builder(
                  builder: (context) {
                    final temRanking = meuRanking != null;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: temRanking ? const Color(0xFFCC0000).withValues(alpha: 0.12) : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.055),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFCC0000),
                                  Color(0xFF8F0000),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFCC0000).withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 13),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Meu Ranking',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (temRanking)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '#${meuRanking?['posicao']}',
                                          style: const TextStyle(
                                            color: Color(0xFFB00000),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  meuRanking?['nomcli'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: temRanking ? Colors.black87 : Colors.grey.shade600,
                                  ),
                                ),

                                const SizedBox(height: 9),

                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade50,
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(
                                          color: Colors.amber.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 15,
                                            color: Colors.amber.shade800,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${rdz(meuRanking!['pontos']!.toString())} pts',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.amber.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    if (temRanking)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          '${meuRanking?['posicao']}º colocado',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFCC0000),
                          Color(0xFF990000),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCC0000).withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.leaderboard_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOP 20 COLOCADOS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Melhores participantes no ranking',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFCC0000)),
              ),
            )
          else if (_ranking.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 18,
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
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.leaderboard_rounded,
                            size: 38,
                            color: Color(0xFFCC0000),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          'Nenhum ranking disponível',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'O ranking será exibido assim que houver palpites calculados em jogos com resultado final.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _ranking[index];

                    final posicao = (item['posicao'] as num).toInt();
                    final nome = item['nomcli'] ?? 'Desconhecido';
                    final pontos = (item['pontos'] as num).toInt();

                    final isMeuRanking = normalizarCpf(item['cpfcli']) == normalizarCpf(meuRanking?['cpfcli']);
                    final isPremiado = posicao <= 5;
                    Color accentColor = Colors.grey.shade400;

                    List<Color> podiumColors = [
                      Colors.white,
                      Colors.white,
                    ];

                    List<Color> posicaoGradient = [
                      Colors.grey.shade100,
                      Colors.grey.shade200,
                    ];

                    List<Color> medalhaColors = [
                      Colors.grey.shade300,
                      Colors.grey.shade500,
                    ];

                    if (posicao == 1) {
                      accentColor = Colors.amber.shade700;

                      podiumColors = const [
                        Color(0xFFFFB300),
                        Color(0xFFFF9800),
                      ];

                      posicaoGradient = [
                        Colors.amber.shade300,
                        Colors.orange.shade700,
                      ];

                      medalhaColors = [
                        Colors.amber.shade300,
                        Colors.orange.shade700,
                      ];
                    }

                    if (posicao == 2) {
                      accentColor = Colors.blueGrey.shade400;

                      podiumColors = const [
                        Color(0xFF9E9E9E),
                        Color(0xFF616161),
                      ];

                      posicaoGradient = [
                        Colors.grey.shade300,
                        Colors.blueGrey.shade500,
                      ];

                      medalhaColors = [
                        Colors.grey.shade300,
                        Colors.blueGrey.shade500,
                      ];
                    }

                    if (posicao == 3) {
                      accentColor = Colors.brown.shade500;

                      podiumColors = const [
                        Color(0xFF8D5A48),
                        Color(0xFF5D4037),
                      ];

                      posicaoGradient = [
                        Colors.orange.shade300,
                        Colors.brown.shade600,
                      ];

                      medalhaColors = [
                        Colors.orange.shade300,
                        Colors.brown.shade600,
                      ];
                    }

                    if (posicao == 4) {
                      accentColor = const Color(0xFF4B5563);

                      podiumColors = const [
                        Color(0xFF5B6472),
                        Color(0xFF3F4752),
                      ];

                      posicaoGradient = const [
                        Color(0xFFA8B0BA),
                        Color(0xFF5B6472),
                      ];

                      medalhaColors = const [
                        Color(0xFFB6BEC8),
                        Color(0xFF6B7280),
                      ];
                    }

                    if (posicao == 5) {
                      accentColor = const Color(0xFF516174);

                      podiumColors = const [
                        Color(0xFF6B7A8F),
                        Color(0xFF4A586A),
                      ];

                      posicaoGradient = const [
                        Color(0xFFB3C0D1),
                        Color(0xFF607086),
                      ];

                      medalhaColors = const [
                        Color(0xFFC2CCD8),
                        Color(0xFF718096),
                      ];
                    }

                    return AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            (1 - _animController.value) * 20 * (index + 1).clamp(0, 5),
                          ),
                          child: Opacity(
                            opacity: _animController.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: isPremiado
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: podiumColors,
                                )
                              : isMeuRanking
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFF7E0),
                                    Color(0xFFFFECB3),
                                  ],
                                )
                              : null,
                          color: isPremiado || isMeuRanking ? null : Colors.white,
                          border: Border.all(
                            width: isMeuRanking ? 2 : 1,
                            color: isMeuRanking
                                ? Colors.amber.shade700
                                : isPremiado
                                ? Colors.white.withValues(alpha: 0.16)
                                : Colors.grey.shade100,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isMeuRanking
                                  ? Colors.amber.withValues(alpha: 0.32)
                                  : isPremiado
                                  ? accentColor.withValues(alpha: 0.28)
                                  : Colors.black.withValues(alpha: 0.045),
                              blurRadius: isMeuRanking
                                  ? 18
                                  : isPremiado
                                  ? 16
                                  : 10,
                              spreadRadius: isMeuRanking
                                  ? -1
                                  : isPremiado
                                  ? -2
                                  : 0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            children: [
                              if (!isPremiado)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 4,
                                    color: accentColor.withValues(alpha: 0.55),
                                  ),
                                ),

                              if (isPremiado)
                                Positioned(
                                  right: -18,
                                  top: -18,
                                  child: Icon(
                                    Icons.emoji_events_rounded,
                                    size: 86,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),

                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: posicaoGradient,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accentColor.withValues(alpha: isPremiado ? 0.38 : 0.18),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$posicao',
                                          style: TextStyle(
                                            color: isPremiado ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nome,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                              color: isPremiado ? Colors.white : Colors.black87,
                                              letterSpacing: 0.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star_rounded,
                                                size: 14,
                                                color: isPremiado ? Colors.white.withValues(alpha: 0.75) : Colors.amber.shade700,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$pontos pontos acumulados',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: isPremiado ? Colors.white.withValues(alpha: 0.78) : Colors.grey.shade600,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    if (isPremiado)
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: medalhaColors,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: medalhaColors[1].withValues(alpha: 0.35),
                                              blurRadius: 12,
                                              spreadRadius: -2,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.45),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.emoji_events_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Text(
                                          '$pontos pts',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: top20Count,
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: SizedBox(height: 92),
          ),
        ],
      ),
    );
  }
}
