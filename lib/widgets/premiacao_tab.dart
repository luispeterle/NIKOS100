import 'package:flutter/material.dart';

// Tela de premiaÃ§Ã£o - mostra os prÃªmios do bolÃ£o
class PremiacaoTab extends StatefulWidget {
  const PremiacaoTab({super.key});

  @override
  State<PremiacaoTab> createState() => _PremiacaoTabState();
}

class _PremiacaoTabState extends State<PremiacaoTab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // AnimaÃ§Ã£o do trofÃ©u - fica pulsando
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header com trofeu animado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFCC0000),
                  Color(0xFF9B0000),
                  Color(0xFF5E0000),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFFCC0000).withValues(alpha: 0.22),
                  blurRadius: 28,
                  spreadRadius: -8,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  right: -22,
                  top: -26,
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 120,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),

                Positioned(
                  left: -35,
                  bottom: -35,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),

                Column(
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final wave = _controller.value;

                        return SizedBox(
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: (1 - wave) * 0.22,
                                child: Transform.scale(
                                  scale: 0.85 + (wave * 0.55),
                                  child: Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.amber.shade200,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Transform.scale(
                                scale: 1.0 + ((1 - wave) * 0.025),
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.18),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withValues(alpha: 0.22),
                                        blurRadius: 18,
                                        spreadRadius: -2,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    width: 78,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.amber.shade300,
                                          Colors.amber.shade500,
                                          Colors.orange.shade700,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.16),
                                          blurRadius: 12,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.emoji_events_rounded,
                                      color: Colors.white,
                                      size: 42,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),

                    const Text(
                      'PREMIAÇÃO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            offset: Offset(0, 3),
                            blurRadius: 7,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sports_soccer_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Lojas Adelino - Copa do Mundo 2026",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Cards de premios
          _buildPremioCard(
            posicao: 1,
            premio: 'R\$ 5.000,00',
            descricao: 'via PIX',
            gradientColors: [
              Colors.amber.shade400,
              Colors.orange.shade700,
            ],
            isGold: true,
          ),

          _buildPremioCard(
            posicao: 2,
            premio: 'TV 50 Polegadas',
            descricao: 'Smart TV LED 4K',
            gradientColors: [Colors.grey.shade400, Colors.grey.shade600],
          ),
          _buildPremioCard(
            posicao: 3,
            premio: 'R\$ 1.000,00',
            descricao: 'em compras no Nikos',
            gradientColors: [Colors.brown.shade400, Colors.brown.shade600],
          ),
          _buildPremioCard(
            posicao: 4,
            premio: 'R\$ 500,00',
            descricao: 'em compras no Nikos',
            gradientColors: [Colors.blueGrey.shade300, Colors.blueGrey.shade500],
          ),
          _buildPremioCard(
            posicao: 5,
            premio: 'R\$ 250,00',
            descricao: 'em compras no Nikos',
            gradientColors: [Colors.blueGrey.shade200, Colors.blueGrey.shade400],
          ),

          const SizedBox(height: 20),

          // Observacao
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.blue.shade100,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue.shade700,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entrega dos prêmios',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Os prêmios serão entregues em até 30 dias após o término do bolão.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 92),
        ],
      ),
    );
  }

  Widget _buildPremioCard({
    required int posicao,
    required String premio,
    required String descricao,
    required List<Color> gradientColors,
    bool isGold = false,
  }) {
    final isTop3 = posicao <= 3;
    final mainColor = gradientColors.first;
    final secondColor = gradientColors.length > 1 ? gradientColors[1] : gradientColors.first;

    IconData icon;
    String label;

    switch (posicao) {
      case 1:
        icon = Icons.emoji_events_rounded;
        label = 'Campeão';
        break;
      case 2:
        icon = Icons.workspace_premium_rounded;
        label = 'Vice-campeão';
        break;
      case 3:
        icon = Icons.military_tech_rounded;
        label = 'Terceiro lugar';
        break;
      default:
        icon = Icons.card_giftcard_rounded;
        label = '$posicaoº colocado';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isGold ? Colors.amber.shade400 : mainColor.withValues(alpha: 0.28),
          width: isGold ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isGold ? Colors.amber.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            spreadRadius: -3,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  Container(
                    width: 7,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          mainColor,
                          secondColor,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            mainColor.withValues(alpha: isGold ? 0.16 : 0.10),
                            Colors.white,
                            Colors.white,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 14,
              top: 12,
              bottom: 12,
              child: Icon(
                icon,
                size: 78,
                color: mainColor.withValues(alpha: 0.08),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          mainColor,
                          secondColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withValues(alpha: 0.32),
                          blurRadius: 12,
                          spreadRadius: -2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          icon,
                          color: Colors.white.withValues(alpha: 0.25),
                          size: 38,
                        ),
                        Text(
                          '$posicaoº',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: mainColor.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: mainColor.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Text(
                                label.toUpperCase(),
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                            if (isGold)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Text(
                                  'PRÊMIO PRINCIPAL',
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 9),

                        Text(
                          premio,
                          style: TextStyle(
                            fontSize: isGold ? 24 : 22,
                            fontWeight: FontWeight.w900,
                            color: isGold ? Colors.orange.shade800 : const Color(0xFFCC0000),
                            height: 1.05,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          descricao,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  if (isTop3) ...[
                    const SizedBox(width: 10),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: mainColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: mainColor.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: mainColor,
                        size: 22,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
