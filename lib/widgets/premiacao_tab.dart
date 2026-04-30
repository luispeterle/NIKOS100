import 'package:flutter/material.dart';

// Tela de premiação - mostra os prêmios do bolão
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
    // Animação do troféu - fica pulsando
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFCC0000), Color(0xFF8B0000), Color(0xFF660000)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade300,
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                // Trofeu animado
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_controller.value * 0.1),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade400, Colors.amber.shade700],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.6),
                              blurRadius: 20 + (_controller.value * 10),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.emoji_events, color: Colors.white, size: 56),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'PREMIAÇÃO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "NIKO'\$ - Copa do Mundo 2026",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
            gradientColors: [Colors.amber.shade400, Colors.amber.shade700],
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.info_outline, color: Colors.blue.shade600, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Os premios serao entregues em ate 30 dias apos o termino do bolao.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isGold ? Border.all(color: Colors.amber.shade300, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: isGold ? Colors.amber.shade200 : Colors.grey.shade200,
            blurRadius: isGold ? 20 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Lado esquerdo com posicao
          Container(
            width: 90,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (posicao <= 3)
                  Icon(
                    Icons.emoji_events,
                    color: Colors.white.withOpacity(0.9),
                    size: 28,
                  ),
                const SizedBox(height: 4),
                Text(
                  '${posicao}º',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Lado direito com detalhes
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${posicao}º Colocado',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    premio,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isGold ? Colors.amber.shade700 : const Color(0xFFCC0000),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Icone lateral
          if (posicao <= 3)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gradientColors[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star,
                  color: gradientColors[0],
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
