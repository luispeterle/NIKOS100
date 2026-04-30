import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nikos/utils/micro_server_post.dart';
import '../widgets/palpites_tab.dart';
import '../widgets/ranking_tab.dart';
import '../widgets/premiacao_tab.dart';
import '../widgets/regulamento_tab.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.user, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // Removido "Conta" conforme solicitado
  final List<String> _tabTitles = ['Palpites', 'Ranking', 'Premios', 'Regras'];
  final List<IconData> _tabIcons = [
    Icons.sports_soccer,
    Icons.leaderboard,
    Icons.emoji_events,
    Icons.menu_book,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header customizado com efeito 3D
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFCC0000), Color(0xFF990000)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade300,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                child: Row(
                  children: [
                    // Logo 3D
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        "NIKO'\$",
                        style: TextStyle(
                          color: Color(0xFFCC0000),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Usuario info
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            (widget.user['nome'] ?? 'Usuario').split(' ').first,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botao logout
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white, size: 22),
                        onPressed: widget.onLogout,
                        tooltip: 'Sair',
                      ),
                    ),
                    if (kDebugMode)
                      IconButton(
                        icon: const Icon(Icons.telegram, color: Colors.white, size: 22),
                        onPressed: () async {
                          final resp = await serverPost(
                            "login_simple",
                            myJson: {
                              "nomusu": "??",
                              "password": "??",
                            },
                          );
                          print(resp);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Tab bar com efeito 3D
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: List.generate(_tabTitles.length, (index) {
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFFCC0000), Color(0xFF990000)],
                              )
                            : null,
                        color: isSelected ? null : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.red.shade200,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _tabIcons[index],
                            size: 18,
                            color: isSelected ? Colors.white : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _tabTitles[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Conteudo
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                PalpitesTab(user: widget.user),
                RankingTab(user: widget.user),
                const PremiacaoTab(),
                const RegulamentoTab(),
              ],
            ),
          ),
        ],
      ),

      // Footer elegante
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFCC0000), Color(0xFF990000)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade300,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.copyright, color: Colors.white.withOpacity(0.7), size: 14),
            const SizedBox(width: 6),
            Text(
              "2026 NIKO'\$ - Todos os direitos reservados",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
