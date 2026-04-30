import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import '../utils/date_utils.dart';

class AdminScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;
  final String adminId;

  const AdminScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.adminId,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> _jogos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadJogos();
  }

  Future<void> _loadJogos() async {
    setState(() => _loading = true);
    final jogos = await ApiService.getJogos();
    setState(() {
      _jogos = jogos;
      _loading = false;
    });
  }

  void _adicionarJogo() {
    final idjogoController = TextEditingController();
    final datjogController = TextEditingController();
    final timeaaController = TextEditingController();
    final siglaaController = TextEditingController();
    final timebbController = TextEditingController();
    final siglbbController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Novo Jogo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idjogoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID do Jogo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: datjogController,
                decoration: const InputDecoration(
                  labelText: 'Data/Hora (DD/MM/AAAA HH:MM)',
                  hintText: '31/12/2026 20:30',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: timeaaController,
                      decoration: const InputDecoration(
                        labelText: 'Time A',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: siglaaController,
                      maxLength: 3,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Sigla',
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: timebbController,
                      decoration: const InputDecoration(
                        labelText: 'Time B',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: siglbbController,
                      maxLength: 3,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Sigla',
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC0000)),
            onPressed: () async {
              final idjogo = idjogoController.text.trim();
              final datjog = datjogController.text.trim();
              final timeaa = timeaaController.text.trim();
              final siglaa = siglaaController.text.trim();
              final timebb = timebbController.text.trim();
              final siglbb = siglbbController.text.trim();

              if (idjogo.isEmpty || datjog.isEmpty || timeaa.isEmpty || siglaa.isEmpty || timebb.isEmpty || siglbb.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos para adicionar o jogo')),
                );
                return;
              }

              final success = await ApiService.salvarJogoAdmin(
                idjogo: idjogo,
                datjog: datjog,
                timeaa: timeaa,
                siglaa: siglaa,
                timebb: timebb,
                siglbb: siglbb,
                plcraa: '',
                plcrbb: '',
              );

              if (!mounted) return;
              if (success) {
                Navigator.pop(context);
                await _loadJogos();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Jogo salvo com sucesso')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao salvar o jogo')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _editarResultado(Map<String, dynamic> jogo) {
    final plcraaController = TextEditingController(
      text: jogo['plcraa']?.toString() ?? '',
    );
    final plcrbbController = TextEditingController(
      text: jogo['plcrbb']?.toString() ?? '',
    );

    final timeA = jogo['timeaa']?.toString() ?? jogo['time1']?.toString() ?? '';
    final timeB = jogo['timebb']?.toString() ?? jogo['time2']?.toString() ?? '';
    final siglaA = jogo['siglaa']?.toString() ?? jogo['sigla1']?.toString() ?? 'A';
    final siglaB = jogo['siglbb']?.toString() ?? jogo['sigla2']?.toString() ?? 'B';
    final fase = jogo['fase']?.toString() ?? '';

    void showFeedback(String message, {bool error = false}) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: error ? const Color(0xFFB00020) : const Color(0xFF159447),
            margin: const EdgeInsets.all(18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: Row(
              children: [
                Icon(
                  error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool salvando = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> salvarResultado() async {
              final gol1 = int.tryParse(plcraaController.text);
              final gol2 = int.tryParse(plcrbbController.text);

              final idjogo = jogo['idjogo']?.toString() ?? jogo['id']?.toString() ?? '';
              final datjog = jogo['datjog']?.toString() ?? jogo['dataHora']?.toString() ?? '';
              final timeaa = jogo['timeaa']?.toString() ?? jogo['time1']?.toString() ?? '';
              final siglaa = jogo['siglaa']?.toString() ?? jogo['sigla1']?.toString() ?? '';
              final timebb = jogo['timebb']?.toString() ?? jogo['time2']?.toString() ?? '';
              final siglbb = jogo['siglbb']?.toString() ?? jogo['sigla2']?.toString() ?? '';

              if (gol1 == null || gol2 == null || idjogo.isEmpty || datjog.isEmpty || timeaa.isEmpty || siglaa.isEmpty || timebb.isEmpty || siglbb.isEmpty) {
                showFeedback('Preencha um placar válido', error: true);
                return;
              }

              setModalState(() => salvando = true);

              final success = await ApiService.salvarJogoAdmin(
                idjogo: idjogo,
                datjog: datjog,
                timeaa: timeaa,
                siglaa: siglaa,
                timebb: timebb,
                siglbb: siglbb,
                plcraa: gol1.toString(),
                plcrbb: gol2.toString(),
              );

              if (!mounted) return;

              setModalState(() => salvando = false);

              if (success) {
                Navigator.of(dialogContext).pop();
                await _loadJogos();
                showFeedback('Resultado salvo com sucesso');
              } else {
                showFeedback('Erro ao salvar resultado', error: true);
              }
            }

            Widget buildScoreField({
              required TextEditingController controller,
              required String label,
            }) {
              return TextField(
                controller: controller,
                enabled: !salvando,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F1F1F),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  labelText: label,
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w800,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFFCC0000),
                      width: 2,
                    ),
                  ),
                ),
              );
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Material(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFCC0000),
                                Color(0xFF960000),
                                Color(0xFF650000),
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.24),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.sports_soccer_rounded,
                                      color: Colors.white,
                                      size: 27,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Editar resultado',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          fase.isEmpty ? 'Informe o placar final' : fase,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.72),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: salvando ? null : () => Navigator.of(dialogContext).pop(),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        timeA.isEmpty ? 'Time A' : timeA,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'X',
                                        style: TextStyle(
                                          color: Color(0xFFCC0000),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        timeB.isEmpty ? 'Time B' : timeB,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: buildScoreField(
                                      controller: plcraaController,
                                      label: siglaA,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'X',
                                          style: TextStyle(
                                            color: Color(0xFFCC0000),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: buildScoreField(
                                      controller: plcrbbController,
                                      label: siglaB,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.info_outline_rounded,
                                        color: Color(0xFFCC0000),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Digite o placar final da partida para atualizar o resultado do jogo.',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12.5,
                                          height: 1.35,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: salvando ? null : () => Navigator.of(dialogContext).pop(),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey.shade800,
                                        side: BorderSide(color: Colors.grey.shade300),
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: salvando ? null : salvarResultado,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFCC0000),
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: Colors.red.shade200,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: salvando
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.4,
                                              ),
                                            )
                                          : const Text(
                                              'Salvar',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                              ),
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
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      plcraaController.dispose();
      plcrbbController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header fixo vermelho
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFCC0000),
                  Color(0xFF9F0000),
                  Color(0xFF760000),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                            child: const Text(
                              "ADMIN",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Olá, ${widget.user['nome'] ?? 'Admin'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            'Painel administrativo',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.68),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onLogout();
                          UserSession.clear();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                size: 18,
                                color: Color(0xFFCC0000),
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Sair',
                                style: TextStyle(
                                  color: Color(0xFFCC0000),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ), // Título e botão adicionar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 520;

                return isSmall
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                      Color(0xFF8B0000),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFCC0000).withValues(alpha: 0.25),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.sports_soccer_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),

                              const SizedBox(width: 12),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gerenciar Jogos',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1F1F1F),
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Controle os jogos do bolão',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF777777),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _adicionarJogo,
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: const Text(
                                'Adicionar Jogo',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFCC0000),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFCC0000),
                                  Color(0xFF8B0000),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(17),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFCC0000).withValues(alpha: 0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.sports_soccer_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gerenciar Jogos',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1F1F1F),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Cadastre partidas, organize confrontos e acompanhe os jogos do bolão.',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF777777),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _adicionarJogo,
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: const Text(
                                'Adicionar Jogo',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFCC0000),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
              },
            ),
          ),

          // Lista de jogos
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _loading
                  ? Center(
                      key: const ValueKey('loading'),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 34,
                              height: 34,
                              child: CircularProgressIndicator(
                                color: Color(0xFFCC0000),
                                strokeWidth: 3,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Carregando jogos...',
                              style: TextStyle(
                                color: Color(0xFF555555),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _jogos.isEmpty
                  ? Center(
                      key: const ValueKey('empty'),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 420),
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.05),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.07),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFCC0000).withValues(alpha: 0.14),
                                      const Color(0xFFCC0000).withValues(alpha: 0.04),
                                    ],
                                  ),
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
                                'Nenhum jogo cadastrado',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF222222),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Adicione o primeiro jogo para começar a gerenciar os resultados do bolão.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13.5,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: _adicionarJogo,
                                  icon: const Icon(Icons.add_rounded, size: 20),
                                  label: const Text(
                                    'Adicionar jogo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFCC0000),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      key: const ValueKey('list'),
                      color: const Color(0xFFCC0000),
                      backgroundColor: Colors.white,
                      onRefresh: _loadJogos,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: _jogos.length,
                        itemBuilder: (context, index) {
                          final jogo = _jogos[index];

                          final dataHoraString = jogo['datjog'] ?? jogo['dataHora'] ?? '';
                          final dataHora = DateTime.tryParse(dataHoraString) ?? DateTime.now();

                          final timeA = '${jogo['timeaa'] ?? jogo['time1'] ?? ''}';
                          final timeB = '${jogo['timebb'] ?? jogo['time2'] ?? ''}';
                          final fase = '${jogo['fase'] ?? 'Jogo cadastrado'}';

                          final finalizado = jogo['plcraa'] != null && jogo['plcrbb'] != null;
                          final statusText = finalizado ? '${jogo['plcraa']} x ${jogo['plcrbb']}' : 'Pendente';

                          final statusColor = finalizado ? const Color(0xFF159447) : const Color(0xFF777777);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.05),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCC0000).withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.sports_soccer_rounded,
                                        color: Color(0xFFCC0000),
                                        size: 24,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fase,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$timeA x $timeB',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF222222),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    IconButton(
                                      onPressed: () => _editarResultado(jogo),
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        color: Color(0xFFCC0000),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month_rounded,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        formatDate(dataHora),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 11,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
