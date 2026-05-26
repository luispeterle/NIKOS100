import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String formatDateFull(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

DateTime? tryParseDatjog(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;

  for (final r in [
    RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})\s+(\d{2}):(\d{2})$'),
    RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$'),
    RegExp(r'^(\d{2})(\d{2})(\d{4})$'),
  ]) {
    final m = r.firstMatch(value);
    if (m != null) {
      return DateTime(
        int.parse(m[3]!),
        int.parse(m[2]!),
        int.parse(m[1]!),
        m.groupCount > 3 ? int.parse(m[4]!) : 0,
        m.groupCount > 4 ? int.parse(m[5]!) : 0,
      );
    }
  }

  return DateTime.tryParse(value.replaceFirst(' ', 'T'));
}

String normalizarCpf(dynamic value) {
  return value.toString().replaceAll(RegExp(r'[^0-9]'), '').padLeft(11, '0');
}

String normalizarTexto(String value) {
  return value
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[áàãâä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòõôö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll('ç', 'c');
}

String rdz(String ns) {
  if (ns.endsWith('.0')) {
    ns = ns.substring(0, ns.length - 2);
  }

  return ns;
}

String formatMoneyValue(String? value, {bool allowNegative = false}) {
  if (value == null) return '';
  value = value.trim();
  if (value.isEmpty) return '';

  // Detecta negativo ANTES de limpar
  bool isNegative = value.startsWith('-');

  // Remove tudo que não é número, vírgula ou ponto
  value = value.replaceAll(RegExp(r'[^0-9.,]'), '');

  if (value.isEmpty) return 'R\$ 0,00';

  // Padroniza separadores
  value = value.replaceAll('.', ',');
  value = value.replaceFirst(RegExp(r'^0+(?=\d)'), '');

  if (value == '0' || value == '0,0' || value == '0,00') {
    return 'R\$ 0,00';
  }

  final parts = value.split(',');
  String inteiro = parts[0].isEmpty ? '0' : parts[0];
  String decimal = parts.length > 1 ? parts[1] : '';

  if (decimal.isEmpty) {
    decimal = '00';
  } else if (decimal.length == 1) {
    decimal = '${decimal}0';
  } else if (decimal.length > 2) {
    decimal = decimal.substring(0, 2);
  }

  // Formata milhar
  inteiro = inteiro.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');

  final formatted = '$inteiro,$decimal';

  // Decide se mostra negativo
  if (isNegative && allowNegative) {
    return 'R\$ -$formatted';
  }

  return 'R\$ $formatted';
}

DateTime? tryParseDatjogFinal(String value) {
  final texto = value.trim();

  final match = RegExp(
    r'^(\d{2})/(\d{2})/(\d{4}) (\d{2}):(\d{2})$',
  ).firstMatch(texto);

  if (match == null) {
    return null;
  }

  final dia = int.parse(match.group(1)!);
  final mes = int.parse(match.group(2)!);
  final ano = int.parse(match.group(3)!);
  final hora = int.parse(match.group(4)!);
  final minuto = int.parse(match.group(5)!);

  if (mes < 1 || mes > 12) return null;
  if (hora < 0 || hora > 23) return null;
  if (minuto < 0 || minuto > 59) return null;

  final data = DateTime(ano, mes, dia, hora, minuto);

  if (data.day != dia || data.month != mes || data.year != ano || data.hour != hora || data.minute != minuto) {
    return null;
  }

  return data;
}

class DateTimeBrInputFormatter extends TextInputFormatter {
  static final _notDigit = RegExp(r'\D');
  static const _sep = {2: '/', 4: '/', 8: ' ', 10: ':'};

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cursorEnd = newValue.selection.baseOffset.clamp(0, newValue.text.length).toInt();

    final cursorDigits = newValue.text.substring(0, cursorEnd).replaceAll(_notDigit, '').length;

    final digits = newValue.text.replaceAll(_notDigit, '');
    final raw = digits.length > 12 ? digits.substring(0, 12) : digits;

    final buffer = StringBuffer();

    for (var i = 0; i < raw.length; i++) {
      buffer
        ..write(_sep[i] ?? '')
        ..write(raw[i]);
    }

    final text = buffer.toString();

    var offset = 0;
    var seenDigits = 0;

    while (offset < text.length && seenDigits < cursorDigits) {
      final code = text.codeUnitAt(offset);
      if (code >= 48 && code <= 57) seenDigits++;
      offset++;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }
}

String formatCpfCnpj(String v) {
  var d = v.replaceAll(RegExp(r'\D'), ''); //onlyDigits

  if (d.length == 10) d = '0$d';

  if (d.length == 11) {
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9, 11)}';
  }
  if (d.length == 14) {
    return '${d.substring(0, 2)}.${d.substring(2, 5)}.${d.substring(5, 8)}/${d.substring(8, 12)}-${d.substring(12, 14)}';
  }
  return d;
}

String getSiglaParaBandeira(String sigla) {
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
    'RSA': 'za',
    'BIH': 'ba',
    'PAR': 'py',
    'HAI': 'ht',
    'CUW': 'cw',
    'CIV': 'ci',
    'TUN': 'tn',
    'CPV': 'cv',
    'EGY': 'eg',
    'AUT': 'at',
    'JOR': 'jo',
    'IRQ': 'iq',
    'ALG': 'dz',
    'COD': 'cd',
    'PAN': 'pa',
    'UZB': 'uz',
  };

  final codigo = siglaParaCodigo[sigla.toUpperCase()];
  if (codigo != null) {
    return codigo;
  }

  if (sigla.length == 2) {
    return sigla.toLowerCase();
  }

  return '';
}

Widget getBandeira(String sigla) {
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

  final codigo = getSiglaParaBandeira(sigla);
  if (codigo.isEmpty) {
    return Container(
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
    );
  }

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      boxShadow: [
        const BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.1),
          blurRadius: 4,
          offset: Offset(0, 2),
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
        errorBuilder: (_, _, _) => Container(
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

int toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim()) ?? 0;
  return 0;
}
