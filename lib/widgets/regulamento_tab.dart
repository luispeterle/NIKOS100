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
            padding: const EdgeInsets.all(28),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  '📜 Regulamento Oficial',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confira as regras completas para participar do bolao e garantir sua chance de ganhar!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.help_outline, color: Colors.blue.shade700, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  'Duvidas?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Entre em contato com o RH ou envie email para bolao@nikos.com.br',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header da secao
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFCC0000), Color(0xFF990000)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      numero,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // Itens
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCC0000),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
