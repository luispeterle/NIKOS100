import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nikos/utils/micro_server_post.dart';
import 'package:nikos/widgets/mostrar_info_bolao.dart';
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
  final List<String> _tabTitles = ['Palpites', 'Ranking', 'Prêmios', 'Regras'];
  final List<IconData> _tabIcons = [
    Icons.sports_soccer,
    Icons.leaderboard,
    Icons.emoji_events,
    Icons.menu_book,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      endDrawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.82,
        child: Drawer(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD00000),
                        Color(0xFFA80000),
                        Color(0xFF760000),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(22),
                      bottomRight: Radius.circular(22),
                    ),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        child: Image.asset(
                          'assets/logo.png',
                          height: 66,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                (widget.user['nome'] ?? 'Usuário').toString().toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.question_mark_outlined,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Informações do Bolão',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'Regras dos palpites e ranking.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          mostrarInformacoesBolao(context);
                        },
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFCC0000),
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Sair da conta',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'Encerrar sessão atual',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onLogout();
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Bolão Copa do Mundo 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFD00000),
                  Color(0xFFA80000),
                  Color(0xFF760000),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  spreadRadius: -4,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: const Color(0xFFCC0000).withValues(alpha: 0.22),
                  blurRadius: 22,
                  spreadRadius: -8,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: -28,
                      top: -18,
                      child: Icon(
                        Icons.sports_soccer_rounded,
                        size: 100,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),

                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                        child: SizedBox(
                          height: isMobile ? 66 : 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: ClipRRect(
                                  child: Image.asset(
                                    'assets/logo.png',
                                    height: isMobile ? 66 : 80,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),

                              if (!isMobile)
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.14),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.16),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.person_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              (widget.user['nome'] ?? 'Usuário').toString().toUpperCase(),
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Spacer(),

                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.14),
                                        ),
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.question_mark_rounded,
                                          color: Colors.white,
                                          size: 21,
                                        ),
                                        onPressed: () {
                                          mostrarInformacoesBolao(context);
                                        },
                                        tooltip: 'Informações',
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.14),
                                        ),
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.logout_rounded,
                                          color: Colors.white,
                                          size: 21,
                                        ),
                                        onPressed: widget.onLogout,
                                        tooltip: 'Sair',
                                      ),
                                    ),

                                    if (kDebugMode) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.14),
                                          ),
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.telegram_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            final resp = await serverPost(
                                              "login_simple",
                                              myJson: {
                                                "nomusu": "??",
                                                "password": "??",
                                              },
                                            );
                                            debugPrint(resp.toString());
                                          },
                                          tooltip: 'Debug',
                                        ),
                                      ),
                                    ],
                                  ],
                                )
                              else
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Builder(
                                    builder: (drawerContext) {
                                      return Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.13),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.16),
                                          ),
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.menu_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            Scaffold.of(drawerContext).openEndDrawer();
                                          },
                                          tooltip: 'Menu',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

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

      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final navBorderRadius = BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          );

          return SafeArea(
            top: false,
            child: SizedBox(
              height: isMobile ? 92 : 96,

              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 16 : 24,
                    0,
                    isMobile ? 16 : 24,
                    0,
                  ),
                  child: ClipRRect(
                    borderRadius: navBorderRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: isMobile ? double.infinity : null,
                        constraints: BoxConstraints(
                          maxWidth: isMobile ? double.infinity : 680,
                        ),
                        height: isMobile ? 72 : 68,
                        padding: EdgeInsets.all(isMobile ? 7 : 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFBFC).withValues(alpha: 0.98),
                          borderRadius: navBorderRadius,
                          border: Border.all(
                            color: const Color(0xFFD8DEE3),
                            width: 1,
                          ),
                        ),
                        child: isMobile
                            ? Row(
                                children: List.generate(_tabTitles.length, (index) {
                                  final isSelected = _selectedIndex == index;

                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: index == _tabTitles.length - 1 ? 0 : 6,
                                      ),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 260),
                                        curve: Curves.easeOutCubic,
                                        width: isMobile ? null : (isSelected ? 150 : 118),
                                        height: isMobile ? double.infinity : 52,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(isMobile ? 22 : 999),
                                          gradient: isSelected
                                              ? const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFFD90000),
                                                    Color(0xFFA80000),
                                                  ],
                                                )
                                              : null,
                                          color: isSelected ? null : Colors.transparent,
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFFCC0000).withValues(alpha: 0.30),
                                                    blurRadius: 18,
                                                    spreadRadius: -7,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(22),
                                            onTap: () {
                                              setState(() => _selectedIndex = index);
                                            },
                                            child: AnimatedScale(
                                              duration: const Duration(milliseconds: 180),
                                              curve: Curves.easeOut,
                                              scale: isSelected ? 1.02 : 1,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    _tabIcons[index],
                                                    size: 20,
                                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _tabTitles[index],
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      height: 1,
                                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                                      color: isSelected ? Colors.white : Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_tabTitles.length, (index) {
                                  final isSelected = _selectedIndex == index;

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index == _tabTitles.length - 1 ? 0 : 10,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 260),
                                      curve: Curves.easeOutCubic,
                                      width: isMobile ? null : (isSelected ? 150 : 118),
                                      height: isMobile ? double.infinity : 52,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(isMobile ? 22 : 999),
                                        gradient: isSelected
                                            ? const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFFD90000),
                                                  Color(0xFFA80000),
                                                ],
                                              )
                                            : null,
                                        color: isSelected ? null : Colors.transparent,
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFFCC0000).withValues(alpha: 0.30),
                                                  blurRadius: 18,
                                                  spreadRadius: -7,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(999),
                                          onTap: () {
                                            setState(() => _selectedIndex = index);
                                          },
                                          child: AnimatedScale(
                                            duration: const Duration(milliseconds: 180),
                                            curve: Curves.easeOut,
                                            scale: isSelected ? 1.02 : 1,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  _tabIcons[index],
                                                  size: 19,
                                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _tabTitles[index],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    letterSpacing: 0.1,
                                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
