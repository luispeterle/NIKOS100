import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nikos/services/api_service.dart';
import 'package:nikos/services/user_session.dart';
import 'package:nikos/utils/date_utils.dart';

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
    if (!mounted) return;
    setState(() => _loading = true);
    final jogos = await ApiService.getJogos();
    if (!mounted) return;
    setState(() {
      _jogos = jogos;
      _loading = false;
    });
  }

  void _adicionarJogo() async {
    final messenger = ScaffoldMessenger.of(context);

    final idjogoController = TextEditingController();
    final datjogController = TextEditingController();
    final timeaaController = TextEditingController();
    final siglaaController = TextEditingController();
    final timebbController = TextEditingController();
    final siglbbController = TextEditingController();
    bool salvando = false;
    String? erro;

    final selecoes = [
      {'pais': 'México', 'sigla': 'MEX'},
      {'pais': 'África do Sul', 'sigla': 'RSA'},
      {'pais': 'Coreia do Sul', 'sigla': 'KOR'},
      {'pais': 'Tchéquia', 'sigla': 'CZE'},
      {'pais': 'Canadá', 'sigla': 'CAN'},
      {'pais': 'Bósnia-Herzegovina', 'sigla': 'BIH'},
      {'pais': 'Estados Unidos', 'sigla': 'USA'},
      {'pais': 'Paraguai', 'sigla': 'PAR'},
      {'pais': 'Austrália', 'sigla': 'AUS'},
      {'pais': 'Turquia', 'sigla': 'TUR'},
      {'pais': 'Catar', 'sigla': 'QAT'},
      {'pais': 'Suíça', 'sigla': 'SUI'},
      {'pais': 'Brasil', 'sigla': 'BRA'},
      {'pais': 'Marrocos', 'sigla': 'MAR'},
      {'pais': 'Haiti', 'sigla': 'HAI'},
      {'pais': 'Escócia', 'sigla': 'SCO'},
      {'pais': 'Alemanha', 'sigla': 'GER'},
      {'pais': 'Curaçao', 'sigla': 'CUW'},
      {'pais': 'Holanda', 'sigla': 'NED'},
      {'pais': 'Japão', 'sigla': 'JPN'},
      {'pais': 'Costa do Marfim', 'sigla': 'CIV'},
      {'pais': 'Equador', 'sigla': 'ECU'},
      {'pais': 'Suécia', 'sigla': 'SWE'},
      {'pais': 'Tunísia', 'sigla': 'TUN'},
      {'pais': 'Espanha', 'sigla': 'ESP'},
      {'pais': 'Cabo Verde', 'sigla': 'CPV'},
      {'pais': 'Bélgica', 'sigla': 'BEL'},
      {'pais': 'Egito', 'sigla': 'EGY'},
      {'pais': 'Arábia Saudita', 'sigla': 'KSA'},
      {'pais': 'Uruguai', 'sigla': 'URU'},
      {'pais': 'Irã', 'sigla': 'IRN'},
      {'pais': 'Nova Zelândia', 'sigla': 'NZL'},
      {'pais': 'Áustria', 'sigla': 'AUT'},
      {'pais': 'Jordânia', 'sigla': 'JOR'},
      {'pais': 'França', 'sigla': 'FRA'},
      {'pais': 'Senegal', 'sigla': 'SEN'},
      {'pais': 'Iraque', 'sigla': 'IRQ'},
      {'pais': 'Noruega', 'sigla': 'NOR'},
      {'pais': 'Argentina', 'sigla': 'ARG'},
      {'pais': 'Argélia', 'sigla': 'ALG'},
      {'pais': 'Portugal', 'sigla': 'POR'},
      {'pais': 'RD Congo', 'sigla': 'COD'},
      {'pais': 'Inglaterra', 'sigla': 'ENG'},
      {'pais': 'Croácia', 'sigla': 'CRO'},
      {'pais': 'Gana', 'sigla': 'GHA'},
      {'pais': 'Panamá', 'sigla': 'PAN'},
      {'pais': 'Uzbequistão', 'sigla': 'UZB'},
      {'pais': 'Colômbia', 'sigla': 'COL'},
    ];

    Map<String, String>? selecaoExata(String value) {
      final texto = normalizarTexto(value);

      for (final item in selecoes) {
        if (normalizarTexto(item['pais']!) == texto || normalizarTexto(item['sigla']!) == texto) {
          return item;
        }
      }

      return null;
    }

    Iterable<Map<String, String>> filtrarSelecoes(String value) {
      final texto = normalizarTexto(value);

      if (texto.isEmpty) {
        return selecoes.take(8);
      }

      return selecoes
          .where((item) {
            final pais = normalizarTexto(item['pais']!);
            final sigla = normalizarTexto(item['sigla']!);

            return pais.contains(texto) || sigla.contains(texto);
          })
          .take(8);
    }

    try {
      await showDialog(
        context: context,
        barrierDismissible: !salvando,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogStateContext, setDialogState) {
              Future<void> salvar() async {
                final idjogo = idjogoController.text.trim();
                final datjogRaw = datjogController.text.trim();
                final timeaa = timeaaController.text.trim();
                final siglaa = siglaaController.text.trim().toUpperCase();
                final timebb = timebbController.text.trim();
                final siglbb = siglbbController.text.trim().toUpperCase();
                final parsedDatjog = tryParseDatjogFinal(datjogRaw);

                if (datjogRaw.isEmpty || timeaa.isEmpty || siglaa.isEmpty || timebb.isEmpty || siglbb.isEmpty) {
                  setDialogState(() {
                    erro = 'Preencha todos os campos para adicionar o jogo.';
                  });
                  return;
                }

                if (parsedDatjog == null) {
                  setDialogState(() {
                    erro = 'Informe uma data e hora válidas. Ex: 31/12/2026 20:30.';
                  });
                  return;
                }

                setDialogState(() {
                  salvando = true;
                  erro = null;
                });

                final success = await ApiService.salvarJogoAdmin(
                  idjogo: idjogo,
                  datjog: formatDateFull(parsedDatjog),
                  timeaa: timeaa,
                  siglaa: siglaa,
                  timebb: timebb,
                  siglbb: siglbb,
                  plcraa: '',
                  plcrbb: '',
                );

                if (!mounted || !dialogContext.mounted) return;

                setDialogState(() {
                  salvando = false;
                });

                if (success) {
                  Navigator.of(dialogContext).pop();

                  await _loadJogos();

                  if (!mounted) return;

                  messenger.showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      content: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text('Jogo salvo com sucesso'),
                        ],
                      ),
                    ),
                  );
                } else {
                  setDialogState(() {
                    erro = 'Erro ao salvar o jogo. Tente novamente.';
                  });
                }
              }

              return Dialog(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                backgroundColor: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(22, 22, 18, 20),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFCC0000),
                                  Color(0xFF990000),
                                  Color(0xFF650000),
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.22),
                                    ),
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
                                        'Adicionar jogo',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 21,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Cadastre uma nova partida da Copa',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: salvando ? null : () => Navigator.of(dialogContext).pop(),
                                  icon: const Icon(Icons.close_rounded),
                                  color: Colors.white,
                                  tooltip: 'Fechar',
                                ),
                              ],
                            ),
                          ),

                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: TextField(
                                          controller: datjogController,
                                          keyboardType: TextInputType.number,
                                          maxLength: 16,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(12),
                                            DateTimeBrInputFormatter(),
                                          ],
                                          decoration:
                                              InputDecoration(
                                                labelText: 'Data e hora',
                                                hintText: '31/12/2026 20:30',
                                                prefixIcon: Icon(
                                                  Icons.event_rounded,
                                                  size: 20,
                                                  color: const Color(0xFFCC0000),
                                                ),
                                                filled: true,
                                                fillColor: Colors.grey.shade50,
                                                labelStyle: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                hintStyle: TextStyle(
                                                  color: Colors.grey.shade400,
                                                  fontSize: 13,
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 15,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFCC0000),
                                                    width: 1.6,
                                                  ),
                                                ),
                                              ).copyWith(
                                                counterText: '',
                                                fillColor: Colors.grey.shade50,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 18),

                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Time A',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  return RawAutocomplete<Map<String, String>>(
                                                    displayStringForOption: (item) => item['pais']!,
                                                    optionsBuilder: (textEditingValue) {
                                                      return filtrarSelecoes(textEditingValue.text);
                                                    },
                                                    onSelected: (item) {
                                                      timeaaController.text = item['pais']!;
                                                      siglaaController.text = item['sigla']!;
                                                      FocusScope.of(context).unfocus();
                                                    },
                                                    fieldViewBuilder: (context, controller, node, onFieldSubmitted) {
                                                      if (controller.text != timeaaController.text) {
                                                        controller.text = timeaaController.text;
                                                      }
                                                      return TextField(
                                                        controller: controller,
                                                        focusNode: node,
                                                        textCapitalization: TextCapitalization.words,
                                                        onChanged: (value) {
                                                          timeaaController.text = value;
                                                          final item = selecaoExata(value);
                                                          siglaaController.text = item?['sigla'] ?? '';
                                                        },
                                                        decoration: InputDecoration(
                                                          labelText: 'Nome da seleção',
                                                          hintText: 'Brasil',
                                                          prefixIcon: Icon(
                                                            Icons.flag_rounded,
                                                            size: 20,
                                                            color: const Color(0xFFCC0000),
                                                          ),
                                                          filled: true,
                                                          fillColor: Colors.grey.shade50,
                                                          labelStyle: TextStyle(
                                                            color: Colors.grey.shade700,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                          hintStyle: TextStyle(
                                                            color: Colors.grey.shade400,
                                                            fontSize: 13,
                                                          ),
                                                          contentPadding: const EdgeInsets.symmetric(
                                                            horizontal: 14,
                                                            vertical: 15,
                                                          ),
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(14),
                                                            borderSide: BorderSide(color: Colors.grey.shade200),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(14),
                                                            borderSide: BorderSide(color: Colors.grey.shade200),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(14),
                                                            borderSide: const BorderSide(
                                                              color: Color(0xFFCC0000),
                                                              width: 1.6,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    optionsViewBuilder: (context, onSelected, options) {
                                                      return Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Material(
                                                          color: Colors.transparent,
                                                          child: Container(
                                                            width: constraints.maxWidth,
                                                            margin: const EdgeInsets.only(top: 6),
                                                            constraints: const BoxConstraints(maxHeight: 220),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.circular(16),
                                                              border: Border.all(color: Colors.grey.shade200),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.black.withValues(alpha: 0.16),
                                                                  blurRadius: 24,
                                                                  offset: const Offset(0, 12),
                                                                ),
                                                              ],
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(16),
                                                              child: ListView.separated(
                                                                padding: const EdgeInsets.symmetric(vertical: 6),
                                                                shrinkWrap: true,
                                                                itemCount: options.length,
                                                                separatorBuilder: (_, _) => Divider(
                                                                  height: 1,
                                                                  color: Colors.grey.shade100,
                                                                ),
                                                                itemBuilder: (context, index) {
                                                                  final item = options.elementAt(index);

                                                                  return InkWell(
                                                                    onTap: () => onSelected(item),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal: 12,
                                                                        vertical: 10,
                                                                      ),
                                                                      child: Row(
                                                                        children: [
                                                                          Container(
                                                                            width: 42,
                                                                            height: 32,
                                                                            alignment: Alignment.center,
                                                                            decoration: BoxDecoration(
                                                                              color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                                                              borderRadius: BorderRadius.circular(11),
                                                                            ),
                                                                            child: Text(
                                                                              item['sigla']!,
                                                                              style: const TextStyle(
                                                                                color: Color(0xFFCC0000),
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w900,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 11),
                                                                          Expanded(
                                                                            child: Text(
                                                                              item['pais']!,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(
                                                                                color: Colors.grey.shade800,
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w800,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextField(
                                                controller: siglaaController,
                                                readOnly: true,
                                                maxLength: 3,
                                                textCapitalization: TextCapitalization.characters,
                                                decoration:
                                                    InputDecoration(
                                                      labelText: 'Sigla',
                                                      hintText: 'BRA',
                                                      prefixIcon: Icon(
                                                        Icons.abc_rounded,
                                                        size: 20,
                                                        color: const Color(0xFFCC0000),
                                                      ),
                                                      filled: true,
                                                      fillColor: Colors.grey.shade50,
                                                      labelStyle: TextStyle(
                                                        color: Colors.grey.shade700,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                      hintStyle: TextStyle(
                                                        color: Colors.grey.shade400,
                                                        fontSize: 13,
                                                      ),
                                                      contentPadding: const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 15,
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(14),
                                                        borderSide: BorderSide(color: Colors.grey.shade200),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(14),
                                                        borderSide: BorderSide(color: Colors.grey.shade200),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(14),
                                                        borderSide: const BorderSide(
                                                          color: Color(0xFFCC0000),
                                                          width: 1.6,
                                                        ),
                                                      ),
                                                    ).copyWith(
                                                      counterText: '',
                                                      fillColor: Colors.grey.shade100,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'VS',
                                      style: TextStyle(
                                        color: Color(0xFFCC0000),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Time B',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  return RawAutocomplete<Map<String, String>>(
                                                    displayStringForOption: (item) => item['pais']!,
                                                    optionsBuilder: (textEditingValue) {
                                                      return filtrarSelecoes(textEditingValue.text);
                                                    },
                                                    onSelected: (item) {
                                                      timebbController.text = item['pais']!;
                                                      siglbbController.text = item['sigla']!;
                                                      FocusScope.of(context).unfocus();
                                                    },
                                                    fieldViewBuilder: (context, controller, node, onFieldSubmitted) {
                                                      if (controller.text != timebbController.text) {
                                                        controller.text = timebbController.text;
                                                      }
                                                      return TextField(
                                                        controller: controller,
                                                        focusNode: node,
                                                        textCapitalization: TextCapitalization.words,
                                                        onChanged: (value) {
                                                          timebbController.text = value;
                                                          final item = selecaoExata(value);
                                                          siglbbController.text = item?['sigla'] ?? '';
                                                        },
                                                        decoration: InputDecoration(
                                                          labelText: 'Nome da seleção',
                                                          hintText: 'Argentina',
                                                          prefixIcon: Icon(
                                                            Icons.flag_rounded,
                                                            size: 20,
                                                            color: const Color(0xFFCC0000),
                                                          ),
                                                          filled: true,
                                                          fillColor: Colors.grey.shade50,
                                                          labelStyle: TextStyle(
                                                            color: Colors.grey.shade700,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                          hintStyle: TextStyle(
                                                            color: Colors.grey.shade400,
                                                            fontSize: 13,
                                                          ),
                                                          contentPadding: const EdgeInsets.symmetric(
                                                            horizontal: 14,
                                                            vertical: 15,
                                                          ),
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(14),
                                                            borderSide: BorderSide(color: Colors.grey.shade200),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(14),
                                                            borderSide: BorderSide(color: Colors.grey.shade200),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(14),
                                                            borderSide: const BorderSide(
                                                              color: Color(0xFFCC0000),
                                                              width: 1.6,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    optionsViewBuilder: (context, onSelected, options) {
                                                      return Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Material(
                                                          color: Colors.transparent,
                                                          child: Container(
                                                            width: constraints.maxWidth,
                                                            margin: const EdgeInsets.only(top: 6),
                                                            constraints: const BoxConstraints(maxHeight: 220),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.circular(16),
                                                              border: Border.all(color: Colors.grey.shade200),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.black.withValues(alpha: 0.16),
                                                                  blurRadius: 24,
                                                                  offset: const Offset(0, 12),
                                                                ),
                                                              ],
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(16),
                                                              child: ListView.separated(
                                                                padding: const EdgeInsets.symmetric(vertical: 6),
                                                                shrinkWrap: true,
                                                                itemCount: options.length,
                                                                separatorBuilder: (_, _) => Divider(
                                                                  height: 1,
                                                                  color: Colors.grey.shade100,
                                                                ),
                                                                itemBuilder: (context, index) {
                                                                  final item = options.elementAt(index);

                                                                  return InkWell(
                                                                    onTap: () => onSelected(item),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal: 12,
                                                                        vertical: 10,
                                                                      ),
                                                                      child: Row(
                                                                        children: [
                                                                          Container(
                                                                            width: 42,
                                                                            height: 32,
                                                                            alignment: Alignment.center,
                                                                            decoration: BoxDecoration(
                                                                              color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                                                              borderRadius: BorderRadius.circular(11),
                                                                            ),
                                                                            child: Text(
                                                                              item['sigla']!,
                                                                              style: const TextStyle(
                                                                                color: Color(0xFFCC0000),
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w900,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 11),
                                                                          Expanded(
                                                                            child: Text(
                                                                              item['pais']!,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(
                                                                                color: Colors.grey.shade800,
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w800,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextField(
                                                controller: siglbbController,
                                                readOnly: true,
                                                maxLength: 3,
                                                textCapitalization: TextCapitalization.characters,

                                                decoration:
                                                    InputDecoration(
                                                      labelText: 'Sigla',
                                                      hintText: 'ARG',
                                                      prefixIcon: Icon(
                                                        Icons.abc_rounded,
                                                        size: 20,
                                                        color: const Color(0xFFCC0000),
                                                      ),
                                                      filled: true,
                                                      fillColor: Colors.grey.shade50,
                                                      labelStyle: TextStyle(
                                                        color: Colors.grey.shade700,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                      hintStyle: TextStyle(
                                                        color: Colors.grey.shade400,
                                                        fontSize: 13,
                                                      ),
                                                      contentPadding: const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 15,
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(14),
                                                        borderSide: BorderSide(color: Colors.grey.shade200),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(14),
                                                        borderSide: BorderSide(color: Colors.grey.shade200),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(14),
                                                        borderSide: const BorderSide(
                                                          color: Color(0xFFCC0000),
                                                          width: 1.6,
                                                        ),
                                                      ),
                                                    ).copyWith(
                                                      counterText: '',
                                                      fillColor: Colors.grey.shade100,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (erro != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(13),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.red.shade100,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            color: Colors.red.shade700,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 9),
                                          Expanded(
                                            child: Text(
                                              erro!,
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade100),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: salvando ? null : () => Navigator.of(dialogContext).pop(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.grey.shade800,
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'CANCELAR',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: salvando ? null : salvar,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFCC0000),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey.shade300,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
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
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.save_rounded, size: 18),
                                              SizedBox(width: 8),
                                              Text(
                                                'SALVAR',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13,
                                                  letterSpacing: 0.6,
                                                ),
                                              ),
                                            ],
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
                ),
              );
            },
          );
        },
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        idjogoController.dispose();
        datjogController.dispose();
        timeaaController.dispose();
        siglaaController.dispose();
        timebbController.dispose();
        siglbbController.dispose();
      });
    }
  }

  void _editarResultado(Map<String, dynamic> jogo) {
    String placarA = jogo['plcraa']?.toString() ?? '';
    String placarB = jogo['plcrbb']?.toString() ?? '';

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
              final gol1 = int.tryParse(placarA);
              final gol2 = int.tryParse(placarB);

              final idjogo = jogo['idjogo']?.toString() ?? '';
              final datjogRaw = jogo['datjog']?.toString() ?? '';
              final timeaa = jogo['timeaa']?.toString() ?? '';
              final siglaa = jogo['siglaa']?.toString() ?? '';
              final timebb = jogo['timebb']?.toString() ?? '';
              final siglbb = jogo['siglbb']?.toString() ?? '';
              final parsedDatjog = tryParseDatjog(datjogRaw);

              if (gol1 == null || gol2 == null || idjogo.isEmpty || datjogRaw.isEmpty || timeaa.isEmpty || siglaa.isEmpty || timebb.isEmpty || siglbb.isEmpty) {
                showFeedback('Preencha um placar valido', error: true);
                return;
              }

              if (parsedDatjog == null) {
                showFeedback('Data do jogo invalida para salvar resultado', error: true);
                return;
              }

              setModalState(() => salvando = true);

              final success = await ApiService.salvarJogoAdmin(
                idjogo: idjogo,
                datjog: formatDateFull(parsedDatjog),
                timeaa: timeaa,
                siglaa: siglaa,
                timebb: timebb,
                siglbb: siglbb,
                plcraa: gol1.toString(),
                plcrbb: gol2.toString(),
              );

              if (!mounted || !dialogContext.mounted) return;

              setModalState(() => salvando = false);

              if (success) {
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                await _loadJogos();
                showFeedback('Resultado salvo com sucesso');
              } else {
                showFeedback('Erro ao salvar resultado', error: true);
              }
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
                    child: SingleChildScrollView(
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
                                      child: TextFormField(
                                        initialValue: placarA,
                                        onChanged: (value) => placarA = value,
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
                                          labelText: siglaA,
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
                                      child: TextFormField(
                                        initialValue: placarB,
                                        onChanged: (value) => placarB = value,
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
                                          labelText: siglaB,
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
              ),
            );
          },
        );
      },
    );
  }

  void _visualizarMetricas() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool carregando = true;
        bool iniciou = false;
        String? erro;
        List<Map<String, dynamic>> metricas = [];

        Future<void> carregar(StateSetter setModalState) async {
          try {
            final metricBolao = await ApiService.getMetricBolao();

            setModalState(() {
              metricas = [
                {
                  'titulo': 'Logins efetuados',
                  'valor': metricBolao.where((item) {
                    return item['event_type']?.toString() == 'login';
                  }).length,
                  'descricao': 'Total de eventos de login registrados',
                  'icone': Icons.login_rounded,
                },
                {
                  'titulo': 'Logins únicos efetuados',
                  'valor': metricBolao
                      .where((item) {
                        return item['event_type']?.toString() == 'login';
                      })
                      .map((item) {
                        return item['cpf']?.toString().replaceAll(RegExp(r'\.0$'), '').trim() ?? '';
                      })
                      .where((cpf) {
                        return cpf.isNotEmpty;
                      })
                      .toSet()
                      .length,
                  'descricao': 'CPFs únicos que acessaram o bolão',
                  'icone': Icons.people_alt_rounded,
                },
                {
                  'titulo': 'Acessos no Site',
                  'valor': metricBolao.where((item) {
                    return item['event_type']?.toString().trim().toLowerCase() == 'home';
                  }).length,
                  'descricao': 'Total de acessos registrados no site',
                  'icone': Icons.home_rounded,
                },
                {
                  'titulo': 'Visitantes únicos no site',
                  'valor': metricBolao
                      .where((item) {
                        return item['event_type']?.toString().trim().toLowerCase() == 'home';
                      })
                      .map((item) {
                        return item['anon_id']?.toString().trim() ?? '';
                      })
                      .where((anonId) {
                        return anonId.isNotEmpty;
                      })
                      .toSet()
                      .length,
                  'descricao': 'Total de acessos únicos no site',
                  'icone': Icons.devices_rounded,
                },
              ];

              carregando = false;
              erro = null;
            });
          } catch (_) {
            setModalState(() {
              carregando = false;
              erro = 'Não foi possível carregar as métricas.';
            });
          }
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            if (!iniciou) {
              iniciou = true;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (dialogContext.mounted) {
                  carregar(setModalState);
                }
              });
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Material(
                    color: const Color(0xFFF7F7F7),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
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
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.22),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.analytics_outlined,
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
                                      'Métricas do bolão',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Resumo dos acessos registrados',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                        ),

                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(18),
                            child: carregando
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 44),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          width: 38,
                                          height: 38,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFFCC0000),
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Carregando métricas...',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : erro != null
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.red.shade100,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color: Colors.red.shade700,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            erro!,
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isSmall = constraints.maxWidth < 560;

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: metricas.length,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: isSmall ? 1 : 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          mainAxisExtent: 124,
                                        ),
                                        itemBuilder: (context, index) {
                                          final item = metricas[index];

                                          return Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.black.withValues(alpha: 0.06),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.07),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 7),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFCC0000).withValues(alpha: 0.10),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Icon(
                                                    item['icone'] as IconData,
                                                    color: const Color(0xFFCC0000),
                                                    size: 26,
                                                  ),
                                                ),

                                                const SizedBox(width: 13),

                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        item['titulo'].toString(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          color: Colors.grey.shade700,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),

                                                      const SizedBox(height: 5),

                                                      Text(
                                                        item['valor'].toString(),
                                                        style: const TextStyle(
                                                          color: Color(0xFF1F1F1F),
                                                          fontSize: 26,
                                                          fontWeight: FontWeight.w900,
                                                        ),
                                                      ),

                                                      const SizedBox(height: 3),

                                                      Text(
                                                        item['descricao'].toString(),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          color: Colors.grey.shade500,
                                                          fontSize: 11.5,
                                                          height: 1.25,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
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
    );
  }

  void _visualizarDetailsPalpites() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool carregando = true;
        bool iniciou = false;
        String? erro;
        List<Map<String, dynamic>> palpitesInfo = [];

        final pesquisaCtrl = TextEditingController();
        String filialSelecionada = 'Todas';
        String compraSelecionada = 'Todas';

        Future<void> carregar(StateSetter setModalState) async {
          try {
            final result = await ApiService.getCliDetails();
            setModalState(() {
              palpitesInfo = result;
              carregando = false;
              erro = null;
            });
          } catch (_) {
            setModalState(() {
              carregando = false;
              erro = 'Não foi possível carregar os dados dos participantes.';
            });
          }
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            if (!iniciou) {
              iniciou = true;
              WidgetsBinding.instance.addPostFrameCallback((_) => carregar(setModalState));
            }

            final totalPorFilial = <String, int>{};
            int totalPalpites = 0;
            for (final item in palpitesInfo) {
              final codfil = '${item['codfil'] ?? 'Sem filial'}';
              totalPorFilial.update(codfil, (qtd) => qtd + 1, ifAbsent: () => 1);
              totalPalpites += toInt(item['qtd_palpites_bolao']);
            }

            final filiais = totalPorFilial.keys.toList()
              ..sort((a, b) {
                if (a == 'Sem filial') return 1;
                if (b == 'Sem filial') return -1;

                return int.parse(a).compareTo(int.parse(b));
              });

            final pesquisa = pesquisaCtrl.text.trim().toLowerCase();

            final listaFiltrada = palpitesInfo.where((item) {
              final codfil = '${item['codfil'] ?? 'Sem filial'}';
              final compraFeita = (item['compra_feita'] ?? item['compras_feitas'] ?? '').toString().toUpperCase();
              final matchCompra = switch (compraSelecionada) {
                'Com compra' => compraFeita == 'S',
                'Sem compra' => compraFeita == 'N',
                _ => true,
              };

              final textoBusca = '${item['codcli']} ${item['nomcli']} ${item['cgccpf']} $codfil'.toLowerCase();

              return textoBusca.contains(pesquisa) && ['Todas', codfil].contains(filialSelecionada) && matchCompra;
            }).toList();

            return Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: Material(
                    color: const Color(0xFFF7F7F7),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
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
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.22),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.leaderboard_rounded,
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
                                      'Resumo dos participantes',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Consulte palpites, títulos e distribuição por filial',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  pesquisaCtrl.dispose();
                                  Navigator.of(dialogContext).pop();
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                        ),

                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(18),
                            child: carregando
                                ? SizedBox(
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.height * 0.65,
                                    child: Center(
                                      child: Container(
                                        width: 320,
                                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(26),
                                          border: Border.all(
                                            color: Colors.black.withValues(alpha: 0.06),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.10),
                                              blurRadius: 24,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 62,
                                              height: 62,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(22),
                                              ),
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 34,
                                                  height: 34,
                                                  child: CircularProgressIndicator(
                                                    color: Color(0xFFCC0000),
                                                    strokeWidth: 3.2,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 18),

                                            const Text(
                                              'Carregando participantes',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color(0xFF1F1F1F),
                                                fontSize: 17,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            Text(
                                              'Aguarde enquanto buscamos os dados do bolão.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                                height: 1.3,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : erro != null
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.red.shade100,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color: Colors.red.shade700,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            erro!,
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isSmall = constraints.maxWidth < 920;

                                      final painelResumo = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(22),
                                              border: Border.all(
                                                color: Colors.black.withValues(alpha: 0.06),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.06),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 7),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Totalizadores',
                                                  style: TextStyle(
                                                    color: Color(0xFF1F1F1F),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Resumo geral dos clientes listados',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),

                                                const SizedBox(height: 16),

                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        padding: const EdgeInsets.all(13),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                                          borderRadius: BorderRadius.circular(17),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              rdz(palpitesInfo.length.toString()),
                                                              style: const TextStyle(
                                                                color: Color(0xFFCC0000),
                                                                fontSize: 23,
                                                                fontWeight: FontWeight.w900,
                                                              ),
                                                            ),
                                                            Text(
                                                              'clientes',
                                                              style: TextStyle(
                                                                color: Colors.grey.shade700,
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.w800,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Container(
                                                        padding: const EdgeInsets.all(13),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade100,
                                                          borderRadius: BorderRadius.circular(17),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              rdz(totalPalpites.toString()),
                                                              style: const TextStyle(
                                                                color: Color(0xFF1F1F1F),
                                                                fontSize: 23,
                                                                fontWeight: FontWeight.w900,
                                                              ),
                                                            ),
                                                            Text(
                                                              'palpites',
                                                              style: TextStyle(
                                                                color: Colors.grey.shade700,
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.w800,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 10),

                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Builder(
                                                        builder: (context) {
                                                          final semCompra = palpitesInfo.where((item) => (item['compra_feita'] ?? '').toString().toUpperCase() == 'N').toList();

                                                          final clientesPorFilial = semCompra.fold<Map<String, List<dynamic>>>({}, (map, item) {
                                                            final filial = (item['codfil'] ?? 'Sem filial').toString();

                                                            map.putIfAbsent(filial, () => []);
                                                            map[filial]!.add(item);

                                                            return map;
                                                          });

                                                          final filiais = clientesPorFilial.entries.toList()
                                                            ..sort((a, b) {
                                                              final fa = int.tryParse(a.key);
                                                              final fb = int.tryParse(b.key);

                                                              if (fa == null && fb == null) return a.key.compareTo(b.key);
                                                              if (fa == null) return 1;
                                                              if (fb == null) return -1;

                                                              return fa.compareTo(fb);
                                                            });

                                                          return Material(
                                                            color: Colors.transparent,
                                                            child: InkWell(
                                                              borderRadius: BorderRadius.circular(22),
                                                              onTap: () {
                                                                showModalBottomSheet(
                                                                  context: context,
                                                                  isScrollControlled: true,
                                                                  useSafeArea: true,
                                                                  backgroundColor: Colors.transparent,
                                                                  builder: (context) {
                                                                    return DraggableScrollableSheet(
                                                                      initialChildSize: 0.58,
                                                                      minChildSize: 0.35,
                                                                      maxChildSize: 0.88,
                                                                      expand: false,
                                                                      builder: (context, scrollController) {
                                                                        return Container(
                                                                          decoration: const BoxDecoration(
                                                                            color: Colors.white,
                                                                            borderRadius: BorderRadius.vertical(
                                                                              top: Radius.circular(28),
                                                                            ),
                                                                          ),
                                                                          child: Column(
                                                                            children: [
                                                                              const SizedBox(height: 10),
                                                                              Container(
                                                                                width: 46,
                                                                                height: 5,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.blueGrey.shade100,
                                                                                  borderRadius: BorderRadius.circular(99),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Container(
                                                                                      padding: const EdgeInsets.all(12),
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.blue.shade50,
                                                                                        borderRadius: BorderRadius.circular(16),
                                                                                      ),
                                                                                      child: Icon(
                                                                                        Icons.people_alt_rounded,
                                                                                        color: Colors.blue.shade700,
                                                                                        size: 26,
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 12),
                                                                                    Expanded(
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            'Clientes sem compra',
                                                                                            style: TextStyle(
                                                                                              color: Colors.blueGrey.shade900,
                                                                                              fontSize: 18,
                                                                                              fontWeight: FontWeight.w900,
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            'Detalhamento por filial na campanha',
                                                                                            style: TextStyle(
                                                                                              color: Colors.blueGrey.shade500,
                                                                                              fontSize: 12,
                                                                                              fontWeight: FontWeight.w700,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    Container(
                                                                                      padding: const EdgeInsets.symmetric(
                                                                                        horizontal: 14,
                                                                                        vertical: 9,
                                                                                      ),
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.blue.shade700,
                                                                                        borderRadius: BorderRadius.circular(99),
                                                                                      ),
                                                                                      child: Text(
                                                                                        rdz(semCompra.length.toString()),
                                                                                        style: const TextStyle(
                                                                                          color: Colors.white,
                                                                                          fontSize: 16,
                                                                                          fontWeight: FontWeight.w900,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                                                child: Container(
                                                                                  padding: const EdgeInsets.all(14),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.blue.shade50,
                                                                                    borderRadius: BorderRadius.circular(18),
                                                                                    border: Border.all(
                                                                                      color: Colors.blue.shade100,
                                                                                    ),
                                                                                  ),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: Text(
                                                                                          'Total sem compra',
                                                                                          style: TextStyle(
                                                                                            color: Colors.blueGrey.shade700,
                                                                                            fontSize: 13,
                                                                                            fontWeight: FontWeight.w800,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Text(
                                                                                        '${rdz(semCompra.length.toString())} clientes',
                                                                                        style: TextStyle(
                                                                                          color: Colors.blue.shade800,
                                                                                          fontSize: 14,
                                                                                          fontWeight: FontWeight.w900,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 10),
                                                                              Expanded(
                                                                                child: filiais.isEmpty
                                                                                    ? Center(
                                                                                        child: Text(
                                                                                          'Nenhum cliente sem compra encontrado.',
                                                                                          style: TextStyle(
                                                                                            color: Colors.blueGrey.shade500,
                                                                                            fontSize: 13,
                                                                                            fontWeight: FontWeight.w700,
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : ListView.separated(
                                                                                        controller: scrollController,
                                                                                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                                                                                        itemCount: filiais.length,
                                                                                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                                                                                        itemBuilder: (context, index) {
                                                                                          final filial = filiais[index];

                                                                                          final clientes = [...filial.value]
                                                                                            ..sort((a, b) {
                                                                                              final nomeA = (a['nomcli'] ?? '').toString();
                                                                                              final nomeB = (b['nomcli'] ?? '').toString();
                                                                                              return nomeA.compareTo(nomeB);
                                                                                            });

                                                                                          final clientesTooltip = clientes
                                                                                              .map((cliente) {
                                                                                                final codcli = (cliente['codcli'] ?? '-').toString();
                                                                                                final nomcli = (cliente['nomcli'] ?? 'Cliente sem nome').toString();

                                                                                                return '$codcli - $nomcli';
                                                                                              })
                                                                                              .join('\n');

                                                                                          return Tooltip(
                                                                                            message: clientesTooltip.isEmpty ? 'Nenhum cliente encontrado' : clientesTooltip,
                                                                                            waitDuration: const Duration(milliseconds: 300),
                                                                                            showDuration: const Duration(seconds: 8),
                                                                                            preferBelow: false,
                                                                                            padding: const EdgeInsets.all(14),
                                                                                            margin: const EdgeInsets.symmetric(horizontal: 20),
                                                                                            constraints: const BoxConstraints(
                                                                                              maxWidth: 460,
                                                                                            ),
                                                                                            decoration: BoxDecoration(
                                                                                              color: const Color(0xFF0F172A).withOpacity(0.96),
                                                                                              borderRadius: BorderRadius.circular(14),
                                                                                              boxShadow: [
                                                                                                BoxShadow(
                                                                                                  color: Colors.black.withOpacity(0.22),
                                                                                                  blurRadius: 18,
                                                                                                  offset: const Offset(0, 8),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                            textStyle: const TextStyle(
                                                                                              color: Colors.white,
                                                                                              fontSize: 12,
                                                                                              height: 1.35,
                                                                                              fontWeight: FontWeight.w700,
                                                                                            ),
                                                                                            child: Container(
                                                                                              padding: const EdgeInsets.all(14),
                                                                                              decoration: BoxDecoration(
                                                                                                color: Colors.grey.shade50,
                                                                                                borderRadius: BorderRadius.circular(18),
                                                                                                border: Border.all(
                                                                                                  color: Colors.grey.shade200,
                                                                                                ),
                                                                                              ),
                                                                                              child: Row(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: 42,
                                                                                                    height: 42,
                                                                                                    alignment: Alignment.center,
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: Colors.blue.shade50,
                                                                                                      borderRadius: BorderRadius.circular(14),
                                                                                                    ),
                                                                                                    child: Icon(
                                                                                                      Icons.storefront_rounded,
                                                                                                      color: Colors.blue.shade700,
                                                                                                      size: 22,
                                                                                                    ),
                                                                                                  ),
                                                                                                  const SizedBox(width: 12),
                                                                                                  Expanded(
                                                                                                    child: Column(
                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                      children: [
                                                                                                        Text(
                                                                                                          filial.key == 'Sem filial' ? 'Sem filial' : 'Filial ${filial.key}',
                                                                                                          style: TextStyle(
                                                                                                            color: Colors.blueGrey.shade900,
                                                                                                            fontSize: 14,
                                                                                                            fontWeight: FontWeight.w900,
                                                                                                          ),
                                                                                                        ),
                                                                                                        Text(
                                                                                                          'Passe o mouse para ver os clientes',
                                                                                                          style: TextStyle(
                                                                                                            color: Colors.blueGrey.shade500,
                                                                                                            fontSize: 11,
                                                                                                            fontWeight: FontWeight.w700,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  Container(
                                                                                                    padding: const EdgeInsets.symmetric(
                                                                                                      horizontal: 13,
                                                                                                      vertical: 8,
                                                                                                    ),
                                                                                                    decoration: BoxDecoration(
                                                                                                      color: Colors.blue.shade700,
                                                                                                      borderRadius: BorderRadius.circular(99),
                                                                                                    ),
                                                                                                    child: Text(
                                                                                                      rdz(filial.value.length.toString()),
                                                                                                      style: const TextStyle(
                                                                                                        color: Colors.white,
                                                                                                        fontSize: 14,
                                                                                                        fontWeight: FontWeight.w900,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: Container(
                                                                padding: const EdgeInsets.all(16),
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      Colors.blue.shade50,
                                                                      Colors.white,
                                                                    ],
                                                                    begin: Alignment.topLeft,
                                                                    end: Alignment.bottomRight,
                                                                  ),
                                                                  borderRadius: BorderRadius.circular(22),
                                                                  border: Border.all(
                                                                    color: Colors.blue.shade100,
                                                                  ),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.blue.shade900.withOpacity(0.08),
                                                                      blurRadius: 18,
                                                                      offset: const Offset(0, 8),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            rdz(semCompra.length.toString()),
                                                                            style: TextStyle(
                                                                              color: Colors.blueGrey.shade900,
                                                                              fontSize: 26,
                                                                              fontWeight: FontWeight.w900,
                                                                              height: 1,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(height: 5),
                                                                          Text(
                                                                            'Clientes sem compra',
                                                                            style: TextStyle(
                                                                              color: Colors.blueGrey.shade800,
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w900,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(height: 2),
                                                                          Text(
                                                                            'na campanha',
                                                                            style: TextStyle(
                                                                              color: Colors.blueGrey.shade500,
                                                                              fontSize: 11,
                                                                              fontWeight: FontWeight.w700,
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
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 14),

                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(22),
                                              border: Border.all(
                                                color: Colors.black.withValues(alpha: 0.06),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.06),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 7),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Clientes por filial',
                                                  style: TextStyle(
                                                    color: Color(0xFF1F1F1F),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Quantidade de registros por código de filial',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),

                                                const SizedBox(height: 14),

                                                if (filiais.isEmpty)
                                                  Text(
                                                    'Nenhuma filial encontrada.',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  )
                                                else
                                                  ...filiais.map((filial) {
                                                    final qtd = totalPorFilial[filial] ?? 0;

                                                    return Container(
                                                      margin: const EdgeInsets.only(bottom: 8),
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                      decoration: BoxDecoration(
                                                        color: filialSelecionada == filial ? const Color(0xFFCC0000).withValues(alpha: 0.08) : Colors.grey.shade100,
                                                        borderRadius: BorderRadius.circular(15),
                                                        border: Border.all(
                                                          color: filialSelecionada == filial ? const Color(0xFFCC0000).withValues(alpha: 0.20) : Colors.transparent,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              filial == 'Sem filial' ? 'Sem filial' : 'Filial $filial',
                                                              style: TextStyle(
                                                                color: filialSelecionada == filial ? const Color(0xFFCC0000) : const Color(0xFF1F1F1F),
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w900,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            child: Text(
                                                              rdz(qtd.toString()),
                                                              style: const TextStyle(
                                                                color: Color(0xFF1F1F1F),
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w900,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );

                                      final painelLista = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(22),
                                              border: Border.all(
                                                color: Colors.black.withValues(alpha: 0.06),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.06),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 7),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Lista de clientes',
                                                            style: TextStyle(
                                                              color: Color(0xFF1F1F1F),
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w900,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            'Pesquise, filtre e ordene os participantes',
                                                            style: TextStyle(
                                                              color: Colors.grey,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                                        borderRadius: BorderRadius.circular(14),
                                                      ),
                                                      child: Text(
                                                        '${rdz(listaFiltrada.length.toString())} exibidos',
                                                        style: const TextStyle(
                                                          color: Color(0xFFCC0000),
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w900,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 14),

                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: TextField(
                                                          controller: pesquisaCtrl,
                                                          onChanged: (_) => setModalState(() {}),
                                                          decoration: InputDecoration(
                                                            hintText: 'Pesquisar por nome, código, CPF ou filial',
                                                            hintStyle: TextStyle(
                                                              color: Colors.grey.shade500,
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                            prefixIcon: const Icon(
                                                              Icons.search_rounded,
                                                              color: Color(0xFFCC0000),
                                                            ),
                                                            suffixIcon: pesquisaCtrl.text.isEmpty
                                                                ? null
                                                                : IconButton(
                                                                    onPressed: () {
                                                                      pesquisaCtrl.clear();
                                                                      setModalState(() {});
                                                                    },
                                                                    icon: const Icon(Icons.close_rounded),
                                                                  ),
                                                            filled: true,
                                                            fillColor: const Color(0xFFF7F7F7),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(17),
                                                              borderSide: BorderSide.none,
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(17),
                                                              borderSide: BorderSide(
                                                                color: Colors.black.withValues(alpha: 0.06),
                                                              ),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(17),
                                                              borderSide: const BorderSide(
                                                                color: Color(0xFFCC0000),
                                                                width: 1.4,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        flex: 1,
                                                        child: DropdownButtonFormField<String>(
                                                          value: compraSelecionada,
                                                          isExpanded: true,
                                                          menuMaxHeight: 320,
                                                          dropdownColor: Colors.white,
                                                          borderRadius: BorderRadius.circular(18),
                                                          icon: const Icon(
                                                            Icons.keyboard_arrow_down_rounded,
                                                            color: Color(0xFFCC0000),
                                                          ),
                                                          style: const TextStyle(
                                                            color: Color(0xFF1F1F1F),
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w800,
                                                          ),
                                                          decoration: InputDecoration(
                                                            labelText: 'Compra feita',
                                                            labelStyle: TextStyle(
                                                              color: Colors.grey.shade700,
                                                              fontWeight: FontWeight.w800,
                                                            ),
                                                            prefixIcon: Container(
                                                              margin: const EdgeInsets.all(8),
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                                                borderRadius: BorderRadius.circular(13),
                                                              ),
                                                              child: const Icon(
                                                                Icons.shopping_bag_rounded,
                                                                color: Color(0xFFCC0000),
                                                                size: 21,
                                                              ),
                                                            ),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(18),
                                                              borderSide: BorderSide.none,
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(18),
                                                              borderSide: BorderSide(
                                                                color: Colors.black.withValues(alpha: 0.07),
                                                              ),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(18),
                                                              borderSide: const BorderSide(
                                                                color: Color(0xFFCC0000),
                                                                width: 1.5,
                                                              ),
                                                            ),
                                                          ),
                                                          selectedItemBuilder: (context) {
                                                            return [
                                                              const Text(
                                                                'Todas',
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              ...['Com compra', 'Sem compra'].map(
                                                                (opcao) => Text(
                                                                  opcao,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ];
                                                          },
                                                          items: [
                                                            DropdownMenuItem(
                                                              value: 'Todas',
                                                              child: Row(
                                                                children: [
                                                                  const Icon(
                                                                    Icons.all_inclusive_rounded,
                                                                    color: Color(0xFFCC0000),
                                                                    size: 20,
                                                                  ),
                                                                  const SizedBox(width: 10),
                                                                  const Expanded(
                                                                    child: Text(
                                                                      'Todas',
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            ...[
                                                              {
                                                                'value': 'Com compra',
                                                                'label': 'Com compra',
                                                                'icon': Icons.check_circle_rounded,
                                                              },
                                                              {
                                                                'value': 'Sem compra',
                                                                'label': 'Sem compra',
                                                                'icon': Icons.remove_circle_rounded,
                                                              },
                                                            ].map(
                                                              (opcao) => DropdownMenuItem(
                                                                value: opcao['value']! as String,
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      width: 30,
                                                                      height: 30,
                                                                      alignment: Alignment.center,
                                                                      decoration: BoxDecoration(
                                                                        color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                                                        borderRadius: BorderRadius.circular(10),
                                                                      ),
                                                                      child: Icon(
                                                                        opcao['icon']! as IconData,
                                                                        color: const Color(0xFFCC0000),
                                                                        size: 18,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(width: 10),
                                                                    Expanded(
                                                                      child: Text(
                                                                        opcao['label']! as String,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: const TextStyle(
                                                                          color: Color(0xFF1F1F1F),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w800,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                          onChanged: (value) {
                                                            setModalState(() {
                                                              compraSelecionada = value ?? 'Todas';
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        flex: 2,
                                                        child: DropdownButtonFormField<String>(
                                                          value: filialSelecionada,
                                                          isExpanded: true,
                                                          menuMaxHeight: 320,
                                                          dropdownColor: Colors.white,
                                                          borderRadius: BorderRadius.circular(18),
                                                          icon: const Icon(
                                                            Icons.keyboard_arrow_down_rounded,
                                                            color: Color(0xFFCC0000),
                                                          ),
                                                          style: const TextStyle(
                                                            color: Color(0xFF1F1F1F),
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w800,
                                                          ),
                                                          decoration: InputDecoration(
                                                            labelText: 'Filial',
                                                            labelStyle: TextStyle(
                                                              color: Colors.grey.shade700,
                                                              fontWeight: FontWeight.w800,
                                                            ),
                                                            prefixIcon: Container(
                                                              margin: const EdgeInsets.all(8),
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                                                borderRadius: BorderRadius.circular(13),
                                                              ),
                                                              child: const Icon(
                                                                Icons.storefront_rounded,
                                                                color: Color(0xFFCC0000),
                                                                size: 21,
                                                              ),
                                                            ),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(18),
                                                              borderSide: BorderSide.none,
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(18),
                                                              borderSide: BorderSide(
                                                                color: Colors.black.withValues(alpha: 0.07),
                                                              ),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(18),
                                                              borderSide: const BorderSide(
                                                                color: Color(0xFFCC0000),
                                                                width: 1.5,
                                                              ),
                                                            ),
                                                          ),
                                                          selectedItemBuilder: (context) {
                                                            return [
                                                              const Text(
                                                                'Todas as filiais',
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              ...filiais.map(
                                                                (filial) => Text(
                                                                  filial == 'Sem filial' ? 'Sem filial' : 'Filial $filial',
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ];
                                                          },
                                                          items: [
                                                            DropdownMenuItem(
                                                              value: 'Todas',
                                                              child: Row(
                                                                children: [
                                                                  const Icon(
                                                                    Icons.all_inclusive_rounded,
                                                                    color: Color(0xFFCC0000),
                                                                    size: 20,
                                                                  ),
                                                                  const SizedBox(width: 10),
                                                                  const Expanded(
                                                                    child: Text(
                                                                      'Todas as filiais',
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            ...filiais.map(
                                                              (filial) => DropdownMenuItem(
                                                                value: filial,
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      width: 30,
                                                                      height: 30,
                                                                      alignment: Alignment.center,
                                                                      decoration: BoxDecoration(
                                                                        color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                                                        borderRadius: BorderRadius.circular(10),
                                                                      ),
                                                                      child: Icon(
                                                                        filial == 'Sem filial' ? Icons.help_outline_rounded : Icons.store_rounded,
                                                                        color: const Color(0xFFCC0000),
                                                                        size: 18,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(width: 10),
                                                                    Expanded(
                                                                      child: Text(
                                                                        filial == 'Sem filial' ? 'Sem filial' : 'Filial $filial',
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: const TextStyle(
                                                                          color: Color(0xFF1F1F1F),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w800,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                          onChanged: (value) {
                                                            setModalState(() {
                                                              filialSelecionada = value ?? 'Todas';
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 12),

                                          if (listaFiltrada.isEmpty)
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(18),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.black.withValues(alpha: 0.06),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.search_off_rounded,
                                                    color: Colors.grey.shade500,
                                                    size: 34,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'Nenhum cliente encontrado',
                                                    style: TextStyle(
                                                      color: Color(0xFF1F1F1F),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w900,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    'Ajuste a pesquisa ou altere o filtro de filial.',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          else
                                            ListView.separated(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: listaFiltrada.length,
                                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                                              itemBuilder: (context, index) {
                                                final item = listaFiltrada[index];

                                                return Container(
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(
                                                      color: Colors.black.withValues(alpha: 0.06),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.06),
                                                        blurRadius: 14,
                                                        offset: const Offset(0, 6),
                                                      ),
                                                    ],
                                                  ),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      final result = await ApiService.getCliDetailsPalpites(item['cgccpf']);
                                                      final palpitesDoCliente = result;

                                                      showDialog(
                                                        context: context,
                                                        barrierDismissible: true,
                                                        builder: (dialogContext) {
                                                          return Dialog(
                                                            backgroundColor: Colors.transparent,
                                                            insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                                                            child: Container(
                                                              width: 720,
                                                              constraints: BoxConstraints(
                                                                maxHeight: MediaQuery.of(context).size.height * 0.86,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFFF7F7F7),
                                                                borderRadius: BorderRadius.circular(28),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.black.withValues(alpha: 0.22),
                                                                    blurRadius: 30,
                                                                    offset: const Offset(0, 14),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(28),
                                                                child: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Container(
                                                                      width: double.infinity,
                                                                      padding: const EdgeInsets.fromLTRB(22, 22, 16, 22),
                                                                      decoration: const BoxDecoration(
                                                                        gradient: LinearGradient(
                                                                          begin: Alignment.topLeft,
                                                                          end: Alignment.bottomRight,
                                                                          colors: [
                                                                            Color(0xFFCC0000),
                                                                            Color(0xFF970000),
                                                                            Color(0xFF620000),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      child: Row(
                                                                        children: [
                                                                          Container(
                                                                            width: 50,
                                                                            height: 50,
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.white.withValues(alpha: 0.16),
                                                                              borderRadius: BorderRadius.circular(17),
                                                                              border: Border.all(
                                                                                color: Colors.white.withValues(alpha: 0.22),
                                                                              ),
                                                                            ),
                                                                            child: const Icon(
                                                                              Icons.sports_soccer_rounded,
                                                                              color: Colors.white,
                                                                              size: 28,
                                                                            ),
                                                                          ),

                                                                          const SizedBox(width: 14),

                                                                          Expanded(
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  '${item['codcli']} - ${item['nomcli']}',
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: const TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontSize: 19,
                                                                                    fontWeight: FontWeight.w900,
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 3),
                                                                                Text(
                                                                                  '${formatCpfCnpj(item['cgccpf'].toString())} • ${palpitesDoCliente.length} palpites',
                                                                                  style: const TextStyle(
                                                                                    color: Colors.white70,
                                                                                    fontSize: 13,
                                                                                    fontWeight: FontWeight.w700,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),

                                                                          IconButton(
                                                                            onPressed: () => Navigator.of(dialogContext).pop(),
                                                                            style: IconButton.styleFrom(
                                                                              backgroundColor: Colors.white.withValues(alpha: 0.14),
                                                                              foregroundColor: Colors.white,
                                                                            ),
                                                                            icon: const Icon(Icons.close_rounded),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    Flexible(
                                                                      child: ListView.separated(
                                                                        padding: const EdgeInsets.all(18),
                                                                        itemCount: palpitesDoCliente.length,
                                                                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                                                                        itemBuilder: (context, index) {
                                                                          final palpite = palpitesDoCliente[index];

                                                                          return Container(
                                                                            padding: const EdgeInsets.all(16),
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(22),
                                                                              border: Border.all(
                                                                                color: Colors.black.withValues(alpha: 0.06),
                                                                              ),
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                  color: Colors.black.withValues(alpha: 0.07),
                                                                                  blurRadius: 16,
                                                                                  offset: const Offset(0, 7),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            child: Column(
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Container(
                                                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.grey.shade100,
                                                                                        borderRadius: BorderRadius.circular(12),
                                                                                      ),
                                                                                      child: Text(
                                                                                        'Jogo ${palpite['idjogo']}',
                                                                                        style: TextStyle(
                                                                                          color: Colors.grey.shade700,
                                                                                          fontSize: 11.5,
                                                                                          fontWeight: FontWeight.w900,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),

                                                                                const SizedBox(height: 14),

                                                                                Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Column(
                                                                                        children: [
                                                                                          Container(
                                                                                            padding: const EdgeInsets.all(4),
                                                                                            decoration: BoxDecoration(
                                                                                              borderRadius: BorderRadius.circular(12),
                                                                                              color: Colors.grey.shade50,
                                                                                              shape: BoxShape.rectangle,
                                                                                              border: Border.all(color: Colors.grey.shade200),
                                                                                            ),
                                                                                            child: getBandeira(palpite['siglaa']),
                                                                                          ),
                                                                                          const SizedBox(height: 8),
                                                                                          Text(
                                                                                            palpite['timeaa'],
                                                                                            maxLines: 2,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            textAlign: TextAlign.center,
                                                                                            style: const TextStyle(
                                                                                              color: Color(0xFF1F1F1F),
                                                                                              fontSize: 12,
                                                                                              height: 1.15,
                                                                                              fontWeight: FontWeight.w900,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),

                                                                                    const SizedBox(width: 12),

                                                                                    Column(
                                                                                      children: [
                                                                                        Text(
                                                                                          'Palpite',
                                                                                          style: TextStyle(
                                                                                            color: Colors.grey.shade600,
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w800,
                                                                                          ),
                                                                                        ),
                                                                                        const SizedBox(height: 5),
                                                                                        Container(
                                                                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                                                                                          decoration: BoxDecoration(
                                                                                            color: const Color(0xFFCC0000).withValues(alpha: 0.09),
                                                                                            borderRadius: BorderRadius.circular(18),
                                                                                            border: Border.all(
                                                                                              color: const Color(0xFFCC0000).withValues(alpha: 0.12),
                                                                                            ),
                                                                                          ),
                                                                                          child: Text(
                                                                                            '${palpite['palpaa']} x ${palpite['palpbb']}',
                                                                                            style: const TextStyle(
                                                                                              color: Color(0xFFCC0000),
                                                                                              fontSize: 25,
                                                                                              fontWeight: FontWeight.w900,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        const SizedBox(height: 8),
                                                                                        Text(
                                                                                          'Resultado: ${palpite['plcraa'] ?? '-'} x ${palpite['plcrbb'] ?? '-'}',
                                                                                          style: TextStyle(
                                                                                            color: Colors.grey.shade700,
                                                                                            fontSize: 12,
                                                                                            fontWeight: FontWeight.w800,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),

                                                                                    const SizedBox(width: 12),

                                                                                    Expanded(
                                                                                      child: Column(
                                                                                        children: [
                                                                                          Container(
                                                                                            padding: const EdgeInsets.all(4),
                                                                                            decoration: BoxDecoration(
                                                                                              borderRadius: BorderRadius.circular(12),
                                                                                              color: Colors.grey.shade50,
                                                                                              shape: BoxShape.rectangle,
                                                                                              border: Border.all(color: Colors.grey.shade200),
                                                                                            ),
                                                                                            child: getBandeira(palpite['siglbb']),
                                                                                          ),
                                                                                          const SizedBox(height: 8),
                                                                                          Text(
                                                                                            palpite['timebb'],
                                                                                            maxLines: 2,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            textAlign: TextAlign.center,
                                                                                            style: const TextStyle(
                                                                                              color: Color(0xFF1F1F1F),
                                                                                              fontSize: 12,
                                                                                              height: 1.15,
                                                                                              fontWeight: FontWeight.w900,
                                                                                            ),
                                                                                          ),
                                                                                        ],
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
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 46,
                                                          height: 46,
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFCC0000).withValues(alpha: 0.09),
                                                            borderRadius: BorderRadius.circular(16),
                                                          ),
                                                          child: const Icon(
                                                            Icons.person_rounded,
                                                            color: Color(0xFFCC0000),
                                                            size: 26,
                                                          ),
                                                        ),

                                                        const SizedBox(width: 14),

                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.grey.shade100,
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                    child: Text(
                                                                      '${((item['codfil'] ?? 'Sem filial').toString() == 'Sem filial') ? 'Sem filial' : 'Filial ${(item['codfil'] ?? 'Sem filial')}'} • Compra feita: ${((item['compra_feita'] ?? 'N').toString() == 'S') ? 'Sim' : 'Não'}',
                                                                      style: TextStyle(
                                                                        color: ((item['compra_feita'] ?? 'N').toString() == 'S') ? Colors.green.shade700 : Colors.red.shade700,
                                                                        fontSize: 11,
                                                                        fontWeight: FontWeight.w900,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              const SizedBox(height: 6),

                                                              Text(
                                                                '${item['codcli']} - ${item['nomcli']}',
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: const TextStyle(
                                                                  color: Color(0xFF1F1F1F),
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.w900,
                                                                ),
                                                              ),

                                                              const SizedBox(height: 5),

                                                              Text(
                                                                'CPF: ${formatCpfCnpj('${item['cgccpf']}')}',
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                  color: Colors.grey.shade600,
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        const SizedBox(width: 12),

                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFFCC0000).withValues(alpha: 0.08),
                                                                borderRadius: BorderRadius.circular(14),
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    rdz(item['qtd_palpites_bolao'].toString()),
                                                                    style: const TextStyle(
                                                                      color: Color(0xFFCC0000),
                                                                      fontSize: 18,
                                                                      fontWeight: FontWeight.w900,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    'palpites',
                                                                    style: TextStyle(
                                                                      color: Colors.grey.shade600,
                                                                      fontSize: 10.5,
                                                                      fontWeight: FontWeight.w800,
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
                                                );
                                              },
                                            ),
                                        ],
                                      );

                                      if (isSmall) {
                                        return Column(
                                          children: [
                                            painelResumo,
                                            const SizedBox(height: 16),
                                            painelLista,
                                          ],
                                        );
                                      }

                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 310,
                                            child: painelResumo,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: painelLista,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFCC0000),
                      Color(0xFF8B0000),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Olá, ${widget.user['nome'] ?? 'Admin'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Painel administrativo',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),

              ListTile(
                leading: const Icon(Icons.add_rounded, color: Color(0xFFCC0000)),
                title: const Text(
                  'Adicionar jogo',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                onTap: () {
                  _adicionarJogo();
                },
              ),
              SizedBox(height: 2),

              ListTile(
                leading: const Icon(Icons.person_search, color: Color(0xFFCC0000)),
                title: const Text(
                  'Detalhes Palpites',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                onTap: () {
                  _visualizarDetailsPalpites();
                },
              ),
              SizedBox(height: 2),
              ListTile(
                leading: const Icon(Icons.analytics_outlined, color: Color(0xFFCC0000)),
                title: const Text(
                  'Visualizar Métricas',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                onTap: () {
                  _visualizarMetricas();
                },
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onLogout();
                      UserSession.clear();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      'Sair',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC0000),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
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
            child: Stack(
              children: [
                Positioned(
                  right: 220,
                  top: -55,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                Positioned(
                  right: -45,
                  bottom: -70,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                ),

                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(21),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.24),
                                  ),
                                ),
                                child: const Text(
                                  'ADMINISTRADOR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10.5,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 7),

                              Text(
                                'Olá, ${widget.user['nome'] ?? 'Admin'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                'Painel administrativo do bolão',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.76),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 14),

                        Builder(
                          builder: (context) {
                            final isMobile = MediaQuery.sizeOf(context).width < 700;

                            Widget botaoTopo({
                              required IconData icon,
                              required String texto,
                              required VoidCallback onTap,
                              bool perigo = false,
                            }) {
                              return Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                elevation: 0,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: onTap,
                                  child: Container(
                                    height: 46,
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.55),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.13),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: (perigo ? Colors.red : const Color(0xFFCC0000)).withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            icon,
                                            size: 17,
                                            color: perigo ? Colors.red.shade700 : const Color(0xFFCC0000),
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        Text(
                                          texto,
                                          style: TextStyle(
                                            color: perigo ? Colors.red.shade700 : const Color(0xFFCC0000),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (isMobile) {
                              return Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () => Scaffold.of(context).openEndDrawer(),
                                  child: Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.13),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.menu_rounded,
                                      size: 24,
                                      color: Color(0xFFCC0000),
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.end,
                              children: [
                                botaoTopo(
                                  icon: Icons.add_rounded,
                                  texto: 'Adicionar jogo',
                                  onTap: () {
                                    _adicionarJogo();
                                  },
                                ),
                                botaoTopo(
                                  icon: Icons.person_search_rounded,
                                  texto: 'Detalhes dos palpites',
                                  onTap: () {
                                    _visualizarDetailsPalpites();
                                  },
                                ),
                                botaoTopo(
                                  icon: Icons.analytics_outlined,
                                  texto: 'Métricas',
                                  onTap: () {
                                    _visualizarMetricas();
                                  },
                                ),
                                botaoTopo(
                                  icon: Icons.logout_rounded,
                                  texto: 'Sair',
                                  perigo: true,
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    widget.onLogout();
                                    UserSession.clear();
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                                            '#${jogo['idjogo']} - $fase',
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
