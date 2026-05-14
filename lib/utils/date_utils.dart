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
