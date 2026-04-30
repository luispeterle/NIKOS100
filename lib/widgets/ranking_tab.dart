import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RankingTab extends StatefulWidget {
  final Map<String, dynamic> user;

  const RankingTab({super.key, required this.user});

  @override
  State<RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends State<RankingTab> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _ranking = [];
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
    if (!mounted) return;
    setState(() {
      _ranking = ranking;
      _lastUpdate = DateTime.now();
      _loading = false;
    });

    _animController.forward(from: 0);
  }

  // Encontra a posiÃ§Ã£o do usuÃ¡rio atual no ranking

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
                            child: const Text(
                              'RANKING DO BOLÃO',
                              textAlign: TextAlign.center,
                              style: TextStyle(
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
                                        '${_ranking.length} participantes',
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.leaderboard, size: 60, color: Colors.grey.shade300),
                    SizedBox(height: 16),
                    Text(
                      'Nenhum ranking disponivel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
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
                      child: _buildRankingItem(item),
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

  Widget _buildRankingItem(Map<String, dynamic> item) {
    final posicao = (item['posicao'] as num).toInt();
    final nome = item['nomcli'] ?? 'Desconhecido';
    final pontos = (item['pontos'] as num).toInt();

    final isPodium = posicao <= 3;
    final podiumColors = _getPodiumColors(posicao);
    final accentColor = _getPosicaoColor(posicao);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isPodium
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: podiumColors,
              )
            : null,
        color: isPodium ? null : Colors.white,
        border: Border.all(
          color: isPodium ? Colors.white.withValues(alpha: 0.16) : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: isPodium ? accentColor.withValues(alpha: 0.28) : Colors.black.withValues(alpha: 0.045),
            blurRadius: isPodium ? 16 : 10,
            spreadRadius: isPodium ? -2 : 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            if (!isPodium)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  color: accentColor.withValues(alpha: 0.55),
                ),
              ),

            if (isPodium)
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
                        colors: _getPosicaoGradient(posicao),
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: isPodium ? 0.38 : 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$posicao',
                        style: TextStyle(
                          color: isPodium ? Colors.white : Colors.black87,
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
                            color: isPodium ? Colors.white : Colors.black87,
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
                              color: isPodium ? Colors.white.withValues(alpha: 0.75) : Colors.amber.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$pontos pontos acumulados',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isPodium ? Colors.white.withValues(alpha: 0.78) : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  if (isPodium)
                    _buildMedalha(posicao)
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
    );
  }

  Widget _buildMedalha(int posicao) {
    final colors = {
      1: [Colors.amber.shade300, Colors.orange.shade700],
      2: [Colors.grey.shade300, Colors.blueGrey.shade500],
      3: [Colors.orange.shade300, Colors.brown.shade600],
    };

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors[posicao]!,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors[posicao]![1].withValues(alpha: 0.35),
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
    );
  }

  List<Color> _getPodiumColors(int posicao) {
    switch (posicao) {
      case 1:
        return [
          Color(0xFFFFB300),
          Color(0xFFFF9800),
        ];
      case 2:
        return [
          Color(0xFF9E9E9E),
          Color(0xFF616161),
        ];
      case 3:
        return [
          Color(0xFF8D5A48),
          Color(0xFF5D4037),
        ];
      default:
        return [
          Colors.white,
          Colors.white,
        ];
    }
  }

  List<Color> _getPosicaoGradient(int posicao) {
    switch (posicao) {
      case 1:
        return [
          Colors.amber.shade300,
          Colors.orange.shade700,
        ];
      case 2:
        return [
          Colors.grey.shade300,
          Colors.blueGrey.shade500,
        ];
      case 3:
        return [
          Colors.orange.shade300,
          Colors.brown.shade600,
        ];
      default:
        return [
          Colors.grey.shade100,
          Colors.grey.shade200,
        ];
    }
  }

  Color _getPosicaoColor(int posicao) {
    switch (posicao) {
      case 1:
        return Colors.amber.shade700;
      case 2:
        return Colors.blueGrey.shade400;
      case 3:
        return Colors.brown.shade500;
      default:
        return Colors.grey.shade400;
    }
  }
}
