import 'dart:html' as html;
import 'package:uuid/uuid.dart';

String getAnonId() {
  const key = 'bolao_anon_id';
  final existing = html.window.localStorage[key];

  if (existing != null && existing.isNotEmpty) {
    return existing;
  }

  final created = const Uuid().v4();
  html.window.localStorage[key] = created;
  return created;
}
