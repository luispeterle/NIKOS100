import 'package:flutter/material.dart';

class RegulamentoTab extends StatelessWidget {
  const RegulamentoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header 3D
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFCC0000),
                  Color(0xFF990000),
                  Color(0xFF690000),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFFCC0000).withValues(alpha: 0.18),
                  blurRadius: 24,
                  spreadRadius: -8,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  right: 2,
                  top: -8,
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 180,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),

                Positioned(
                  left: -34,
                  bottom: -34,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Regulamento Oficial',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Confira as regras completas para participar do bolão e garantir sua chance de ganhar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.rule_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Bolão Copa do Mundo 2026',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
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
          const SizedBox(height: 24),

          _buildSection(
            numero: '1',
            titulo: 'INSCRIÇÃO',
            icon: Icons.person_add,
            items: [
              'Inscrição mediante pagamento de R\$ 5,00 por jogo ou R\$ 520,00 para todos os 104 jogos.',
              'O pagamento deve ser feito via PIX ou diretamente no RH.',
            ],
          ),
          _buildSection(
            numero: '2',
            titulo: 'JOGOS',
            icon: Icons.sports_soccer,
            items: [
              'O bolao contempla todos os 104 jogos da Copa do Mundo 2026.',
              '72 jogos da fase de grupos.',
              '32 jogos da fase eliminatoria (oitavas, quartas, semi, disputa 3º e final).',
            ],
          ),
          _buildSection(
            numero: '3',
            titulo: 'PALPITES',
            icon: Icons.edit_note,
            items: [
              'Os palpites podem ser registrados ate 1 hora antes do inicio de cada jogo.',
              'Apos esse prazo, o sistema bloqueia automaticamente os palpites.',
              'Cada participante pode alterar seu palpite quantas vezes quiser ate o bloqueio.',
            ],
          ),
          _buildSection(
            numero: '4',
            titulo: 'PONTUAÇÃO',
            icon: Icons.stars,
            items: [
              'Acerto do placar exato: 20 pontos.',
              'Acerto do vencedor/empate (sem acertar o placar): 10 pontos.',
              'Jogos do Brasil e a Final valem PONTUAÇÃO EM DOBRO.',
            ],
          ),
          _buildSection(
            numero: '5',
            titulo: 'RANKING',
            icon: Icons.leaderboard,
            items: [
              'O ranking é atualizado a cada 5 minutos.',
              'Exibe os Top 5 colocados.',
            ],
          ),
          _buildSection(
            numero: '6',
            titulo: 'PREMIAÇÃO',
            icon: Icons.emoji_events,
            items: [
              '1º Lugar: R\$ 5.000,00 via PIX.',
              '2º Lugar: TV 50 Polegadas Smart LED.',
              '3º Lugar: R\$ 1.000,00 em compras.',
              '4º Lugar: R\$ 500,00 em compras.',
              '5º Lugar: R\$ 250,00 em compras.',
            ],
          ),
          _buildSection(
            numero: '7',
            titulo: 'DESEMPATE',
            icon: Icons.balance,
            items: [
              'Em caso de empate na pontuação final:',
              '1. Maior número de placares exatos.',
              '2. Maior número de acertos de vencedor/empate.',
              '3. Sorteio entre os empatados.',
            ],
          ),
          _buildSection(
            numero: '8',
            titulo: 'DISPOSIÇÕES GERAIS',
            icon: Icons.gavel,
            items: [
              'Casos omissos serão resolvidos pela comissão organizadora.',
              'A participação implica na aceitação integral deste regulamento.',
              'Qualquer tentativa de fraude resulta em desclassificação imediata.',
            ],
          ),

          const SizedBox(height: 24),

          // Contato
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  right: -8,
                  top: -8,
                  child: Icon(
                    Icons.help_outline_rounded,
                    size: 180,
                    color: Colors.blue.shade700.withValues(alpha: 0.07),
                  ),
                ),

                Positioned(
                  left: -36,
                  bottom: -36,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.shade100.withValues(alpha: 0.35),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(22),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.shade200,
                          ),
                        ),
                        child: Icon(
                          Icons.help_outline_rounded,
                          color: Colors.blue.shade700,
                          size: 26,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Dúvidas?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: Colors.blue.shade900,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Entre em contato com o RH ou envie um e-mail para:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.blue.shade100,
                          ),
                        ),
                        child: Text(
                          'bolao@nikos.com.br',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
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

  Widget _buildSection({
    required String numero,
    required String titulo,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            spreadRadius: -3,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFCC0000),
                    Color(0xFF990000),
                    Color(0xFF750000),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        numero,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.6,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isLast = index == items.length - 1;

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Color(0xFFCC0000),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
