import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';

class PalpitesTab extends StatefulWidget {
  final Map<String, dynamic> user;

  const PalpitesTab({super.key, required this.user});

  @override
  State<PalpitesTab> createState() => _PalpitesTabState();
}

class _PalpitesTabState extends State<PalpitesTab> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _jogos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final jogos = await ApiService.getJogos();

    setState(() {
      _jogos = jogos;
      _loading = false;
    });
  }

  // Converte sigla para código de bandeira
  String _getSiglaParaBandeira(String sigla) {
    final Map<String, String> siglaParaCodigo = {
      'QAT': 'qa',
      'ECU': 'ec',
      'ENG': 'gb-eng',
      'IRN': 'ir',
      'ARG': 'ar',
      'KSA': 'sa',
      'GER': 'de',
      'JPN': 'jp',
      'BRA': 'br',
      'SRB': 'rs',
      'POR': 'pt',
      'GHA': 'gh',
      'FRA': 'fr',
      'DEN': 'dk',
      'ESP': 'es',
      'CRO': 'hr',
      'NED': 'nl',
      'USA': 'us',
      'MAR': 'ma',
      'BEL': 'be',
      'MEX': 'mx',
      'CAN': 'ca',
      'ITA': 'it',
      'URU': 'uy',
      'COL': 'co',
      'CHI': 'cl',
      'PER': 'pe',
      'KOR': 'kr',
      'AUS': 'au',
      'NZL': 'nz',
      'NGA': 'ng',
      'SEN': 'sn',
      'UAE': 'ae',
      'POL': 'pl',
      'SUI': 'ch',
      'SWE': 'se',
      'NOR': 'no',
      'FIN': 'fi',
      'ISL': 'is',
      'TUR': 'tr',
      'GRE': 'gr',
      'CZE': 'cz',
      'HUN': 'hu',
      'SCO': 'gb-sct',
      'IRL': 'ie',
      'WAL': 'gb-wls',
      'UKR': 'ua',
      'CRC': 'cr',
    };
    return siglaParaCodigo[sigla.toUpperCase()] ?? sigla.toLowerCase();
  }

  Widget _getBandeira(String sigla) {
    if (sigla.isEmpty) {
      return Container(
        width: 50,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.flag, color: Colors.grey, size: 20),
      );
    }

    final codigo = _getSiglaParaBandeira(sigla);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          'https://flagcdn.com/w80/$codigo.png',
          width: 50,
          height: 35,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 50,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                sigla,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DateTime? _parseDatjog(String datjog) {
    try {
      final normalizada = datjog.trim().replaceFirst('T', ' ');
      final partes = normalizada.split(' ');
      if (partes.length < 2) return null;

      final dataPartes = partes[0].split('-');
      final horaPartes = partes[1].split(':');
      if (dataPartes.length != 3 || horaPartes.length < 2) return null;

      return DateTime(
        int.parse(dataPartes[0]),
        int.parse(dataPartes[1]),
        int.parse(dataPartes[2]),
        int.parse(horaPartes[0]),
        int.parse(horaPartes[1]),
      );
    } catch (e) {
      return null;
    }
  }

  bool _podeEditarPalpite(String datjog) {
    final dataJogo = _parseDatjog(datjog);
    if (dataJogo == null) return false;

    final hoje = DateTime.now();
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    final dataJogoSemHora = DateTime(dataJogo.year, dataJogo.month, dataJogo.day);

    return dataJogoSemHora.isAfter(hojeSemHora);
  }

  // Formata data para exibição
  String _formatarData(String datjog) {
    try {
      final partes = datjog.split(' ');
      final dataPartes = partes[0].split('-');
      final hora = partes[1].substring(0, 5);
      return '${dataPartes[2]}/${dataPartes[1]} $hora';
    } catch (e) {
      return datjog;
    }
  }

  // Verifica se é jogo do Brasil (pontos em dobro)
  bool _ehJogoDoBrasil(Map<String, dynamic> jogo) {
    final siglaa = (jogo['siglaa'] ?? '').toString().toUpperCase();
    final siglbb = (jogo['siglbb'] ?? '').toString().toUpperCase();
    return siglaa == 'BRA' || siglbb == 'BRA';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Info de palpites restantes
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade100, Colors.amber.shade200],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_soccer, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Palpites: ${UserSession.palpitesFeitos}/${UserSession.maxPalpites ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_jogos.length} jogos',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de jogos
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _jogos.length,
                  itemBuilder: (ctx, i) => _buildJogoCard(_jogos[i]),
                ),
              ),
            ),
          ],
        ),

        // Loading
        if (_loading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFCC0000)),
                    SizedBox(height: 20),
                    Text('Carregando jogos...', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildJogoCard(Map<String, dynamic> jogo) {
    final idjogo = jogo['idjogo'];
    final datjog = jogo['datjog'] ?? '';
    final timeaa = jogo['timeaa'] ?? '';
    final siglaa = jogo['siglaa'] ?? '';
    final timebb = jogo['timebb'] ?? '';
    final siglbb = jogo['siglbb'] ?? '';
    final plcraa = jogo['plcraa'];
    final plcrbb = jogo['plcrbb'];
    final usupla = jogo['usupla'];
    final usuplb = jogo['usuplb'];
    final podeEditar = _podeEditarPalpite(datjog);
    final temPlacarOficial = plcraa != null && plcrbb != null && (plcraa != 0 || plcrbb != 0);

    // Jogo só pode ser tratado como finalizado quando já está bloqueado por data
    final jogoFinalizado = !podeEditar && temPlacarOficial;
    final ehBrasil = _ehJogoDoBrasil(jogo);

    final Map<String, dynamic>? palpiteServidor = usupla != null && usuplb != null
        ? {
            'palpaa': usupla,
            'palpbb': usuplb,
          }
        : null;
    final palpiteAtual = palpiteServidor;

    final gol1Controller = TextEditingController(text: palpiteAtual == null ? '' : '${palpiteAtual['palpaa']}');
    final gol2Controller = TextEditingController(text: palpiteAtual == null ? '' : '${palpiteAtual['palpbb']}');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ehBrasil ? Colors.green.shade200 : Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header do card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ehBrasil ? [Colors.green.shade100, Colors.yellow.shade100] : [Colors.grey.shade100, Colors.grey.shade200],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 16,
                      color: ehBrasil ? Colors.green.shade700 : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Jogo #$idjogo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: ehBrasil ? Colors.green.shade800 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (ehBrasil)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF009739), Color(0xFFFFDF00)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              '2X',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            _formatarData(datjog),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Conteudo do card
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Times e placar
                Row(
                  children: [
                    // Time 1
                    Expanded(
                      child: Column(
                        children: [
                          _getBandeira(siglaa),
                          const SizedBox(height: 8),
                          Text(
                            timeaa,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),

                    // Placar / Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          // Se jogo finalizado, mostra placar oficial
                          if (jogoFinalizado)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$plcraa X $plcrbb',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          // Campo de palpite (se pode editar)
                          if (!jogoFinalizado && podeEditar)
                            Row(
                              children: [
                                _buildScoreInput(gol1Controller),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    'X',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                _buildScoreInput(gol2Controller),
                              ],
                            ),

                          // Mostra palpite já feito (se existe e não pode editar)
                          if (!jogoFinalizado && !podeEditar && palpiteAtual != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFCC0000), Color(0xFF990000)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${palpiteAtual['palpaa']} X ${palpiteAtual['palpbb']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          // Sem palpite e bloqueado
                          if (!jogoFinalizado && !podeEditar && palpiteAtual == null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '- X -',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Time 2
                    Expanded(
                      child: Column(
                        children: [
                          _getBandeira(siglbb),
                          const SizedBox(height: 8),
                          Text(
                            timebb,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Status / Botão
                if (jogoFinalizado)
                  _buildStatusContainer(
                    icon: Icons.check_circle,
                    text: 'Jogo finalizado',
                    color: Colors.grey,
                  )
                else if (!podeEditar)
                  _buildStatusContainer(
                    icon: Icons.timer_off,
                    text: 'Palpites bloqueados',
                    color: Colors.orange,
                  )
                else if (!UserSession.canMakePalpite() && palpiteAtual == null)
                  _buildStatusContainer(
                    icon: Icons.block,
                    text: 'Limite de palpites atingido',
                    color: Colors.red,
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final palpaa = gol1Controller.text;
                        final palpbb = gol2Controller.text;

                        if (palpaa.isEmpty || palpbb.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Preencha o placar dos dois times'),
                              backgroundColor: Colors.orange.shade600,
                            ),
                          );
                          return;
                        }

                        setState(() => _loading = true);

                        final sucesso = await ApiService.salvarPalpite(
                          idjogo: idjogo.toString(),
                          palpaa: palpaa,
                          palpbb: palpbb,
                        );
                        await _loadData();
                        if (!mounted) return;

                        if (sucesso) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text('Palpite salvo!'),
                                ],
                              ),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text('Erro ao salvar palpite'),
                                ],
                              ),
                              backgroundColor: Colors.red.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC0000),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        shadowColor: Colors.red.shade300,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            palpiteAtual != null ? Icons.edit : Icons.save,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            palpiteAtual != null ? 'EDITAR PALPITE' : 'SALVAR PALPITE',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Colors.white,
                              fontSize: 13,
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
    );
  }

  Widget _buildScoreInput(TextEditingController controller) {
    return Container(
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFFCC0000),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCC0000), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildStatusContainer({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
