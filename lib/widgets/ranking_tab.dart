import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';

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

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadRanking();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadRanking() async {
    setState(() => _loading = true);
    
    final ranking = await ApiService.getRanking();
    
    setState(() {
      _ranking = ranking;
      _lastUpdate = DateTime.now();
      _loading = false;
    });

    _animController.forward(from: 0);
  }

  // Encontra a posição do usuário atual no ranking
  Map<String, dynamic>? _getUserRanking() {
    final cpf = UserSession.cgccpf;
    if (cpf == null) return null;
    
    // O CPF do usuário pode aparecer no ranking se tiver pontuação
    for (var item in _ranking) {
      // Verifica se é o usuário logado (pode ser pelo nome ou outro identificador)
      // Como a API retorna nomcli, verificamos pelo nome
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Header com info do usuário
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFCC0000), Color(0xFF8B0000), Color(0xFF660000)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade300,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'RANKING DO BOLAO',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '${_ranking.length} participantes',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFCC0000),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info de atualização
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade50, Colors.amber.shade100],
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.amber.shade200),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.info_outline, color: Colors.amber.shade800, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Atualiza a cada 5 min. Ultima: ${_lastUpdate != null ? "${_lastUpdate!.hour.toString().padLeft(2, '0')}:${_lastUpdate!.minute.toString().padLeft(2, '0')}" : "-"}',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _loadRanking,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Atualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.amber.shade300,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFCC0000), Color(0xFF990000)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.leaderboard, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'TOP 20 COLOCADOS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Lista do ranking
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFCC0000)))
                  : _ranking.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.leaderboard, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum ranking disponivel',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadRanking,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _ranking.length > 20 ? 20 : _ranking.length,
                            itemBuilder: (context, index) {
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
                          ),
                        ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> item) {
    final posicao = (item['posicao'] as num).toInt();
    final nome = item['nomcli'] ?? 'Desconhecido';
    final pontos = (item['pontos'] as num).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: posicao <= 3
            ? LinearGradient(
                colors: _getPodiumColors(posicao),
              )
            : null,
        color: posicao > 3 ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: posicao <= 3 
                ? _getPodiumColors(posicao)[0].withOpacity(0.3) 
                : Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Posição
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getPosicaoGradient(posicao),
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _getPosicaoColor(posicao).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$posicao',
                  style: TextStyle(
                    color: posicao <= 3 ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Nome
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: posicao <= 3 ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$pontos pts',
                    style: TextStyle(
                      fontSize: 12,
                      color: posicao <= 3 ? Colors.white70 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Medalha para top 3
            if (posicao <= 3) _buildMedalha(posicao),
          ],
        ),
      ),
    );
  }

  Widget _buildMedalha(int posicao) {
    final colors = {
      1: [Colors.amber, Colors.amber.shade700],
      2: [Colors.grey.shade400, Colors.grey.shade600],
      3: [Colors.brown.shade400, Colors.brown.shade600],
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors[posicao]!,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors[posicao]![0].withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.emoji_events,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  List<Color> _getPodiumColors(int posicao) {
    switch (posicao) {
      case 1:
        return [Colors.amber.shade600, Colors.amber.shade800];
      case 2:
        return [Colors.grey.shade500, Colors.grey.shade700];
      case 3:
        return [Colors.brown.shade500, Colors.brown.shade700];
      default:
        return [Colors.white, Colors.white];
    }
  }

  List<Color> _getPosicaoGradient(int posicao) {
    switch (posicao) {
      case 1:
        return [Colors.amber.shade300, Colors.orange.shade700];
      case 2:
        return [Colors.grey.shade400, Colors.grey.shade600];
      case 3:
        return [Colors.brown.shade400, Colors.brown.shade600];
      default:
        return [Colors.grey.shade200, Colors.grey.shade300];
    }
  }

  Color _getPosicaoColor(int posicao) {
    switch (posicao) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.grey.shade400;
    }
  }
}
