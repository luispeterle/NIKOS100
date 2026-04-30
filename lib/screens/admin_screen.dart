import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../utils/date_utils.dart' as date_utils;

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
  int _selectedTab = 0;
  final List<String> _tabs = ['Jogos', 'Usuarios', 'Logs'];
  final List<IconData> _tabIcons = [Icons.sports_soccer, Icons.people, Icons.history];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header fixo vermelho
          Container(
            color: const Color(0xFFCC0000),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const Text(
                    "ADMIN",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  Text('Olá, ${widget.user['nome']}', style: const TextStyle(color: Colors.white70)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: widget.onLogout,
                  ),
                ],
              ),
            ),
          ),
          // Tabs simples com linha embaixo
          Container(
            color: Colors.white,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTab == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? const Color(0xFFCC0000) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _tabIcons[index],
                            size: 20,
                            color: isSelected ? const Color(0xFFCC0000) : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFCC0000) : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Conteúdo das tabs
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _JogosTab(adminId: widget.adminId), // ✅ Agora usa widget.adminId
                const _UsuariosTab(),
                const _LogsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JogosTab extends StatefulWidget {
  final String adminId;
  const _JogosTab({required this.adminId});

  @override
  State<_JogosTab> createState() => _JogosTabState();
}

class _JogosTabState extends State<_JogosTab> {
  List<Map<String, dynamic>> _jogos = [];
  String _filtroFase = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadJogos();
  }

  void _loadJogos() {
    setState(() => _jogos = DataService.getJogos());
  }

  List<Map<String, dynamic>> get _jogosFiltrados {
    if (_filtroFase == 'Todos') return _jogos;
    return _jogos.where((j) => j['fase'] == _filtroFase).toList();
  }

  List<String> get _fases {
    final fases = _jogos.map((j) => j['fase'] as String).toSet().toList();
    return ['Todos', ...fases];
  }

  void _editarResultado(Map<String, dynamic> jogo) {
    final gol1Controller = TextEditingController(text: jogo['golsTime1']?.toString() ?? '');
    final gol2Controller = TextEditingController(text: jogo['golsTime2']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${jogo['time1']} x ${jogo['time2']}'),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: gol1Controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: jogo['time1'],
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('X', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: TextField(
                controller: gol2Controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: jogo['time2'],
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC0000), foregroundColor: Colors.white),
            onPressed: () {
              final gol1 = int.tryParse(gol1Controller.text);
              final gol2 = int.tryParse(gol2Controller.text);

              if (gol1 != null && gol2 != null) {
                final updatedJogo = {...jogo, 'golsTime1': gol1, 'golsTime2': gol2, 'finalizado': true};
                DataService.updateJogo(updatedJogo);
                DataService.addLog('RESULTADO', '${jogo['time1']} $gol1 x $gol2 ${jogo['time2']}', widget.adminId);
                _loadJogos();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resultado salvo!'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.filter_list, color: Color(0xFFCC0000)),
              const SizedBox(width: 12),
              const Text('Filtrar:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filtroFase,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: _fases.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (v) => setState(() => _filtroFase = v!),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _jogosFiltrados.length,
            itemBuilder: (context, index) {
              final jogo = _jogosFiltrados[index];
              final dataHora = DateTime.parse(jogo['dataHora']);
              final finalizado = jogo['finalizado'] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text('${jogo['time1']} x ${jogo['time2']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${jogo['fase']} - ${date_utils.formatDate(dataHora)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: finalizado ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          finalizado ? '${jogo['golsTime1']} x ${jogo['golsTime2']}' : 'Pendente',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFCC0000)),
                        onPressed: () => _editarResultado(jogo),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UsuariosTab extends StatelessWidget {
  const _UsuariosTab();

  @override
  Widget build(BuildContext context) {
    final users = AuthService.getAllUsers();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final completo = user['todosJogosLiberados'] == true;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFCC0000),
              child: Text(
                user['nome'][0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(user['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CPF: ${user['cpf']}'),
                Row(
                  children: [
                    const Icon(Icons.stars, size: 14, color: Colors.amber),
                    Text('${user['pontos']} pontos'),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: completo ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                completo ? 'COMPLETO' : 'PARCIAL',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogsTab extends StatelessWidget {
  const _LogsTab();

  @override
  Widget build(BuildContext context) {
    final logs = DataService.getLogs();

    if (logs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 20),
            Text('Nenhum log registrado', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final timestamp = DateTime.parse(log['timestamp']);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.history, color: Colors.blue),
            ),
            title: Text(log['action'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(log['details']),
            trailing: Text(date_utils.formatDateFull(timestamp)),
          ),
        );
      },
    );
  }
}
