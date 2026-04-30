import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';

String? globalAcess;
String? _kemPublic;
String globalTokenInicialNginx = "";

const String urlRust = String.fromEnvironment('URL_RUST', defaultValue: 'http://127.0.0.1:5001'); // Url Debug
Future<void> getToken() async {
  await carregarTokenInicialNginx();
  globalAcess = null;
  await serverPost("$urlRust/pre_data_810fil");
}

Future<void> carregarTokenInicialNginx() async {
  if (kIsWeb) return;
  try {
    final response = await http.get(Uri.parse('https://simple.lojasadelino.com.br/pdv'));
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      globalTokenInicialNginx = setCookie.split(';').first.trim();
    }
  } catch (_) {}
}

void aplicarHeaderTokenInicialNginx(Map<String, String> headers) {
  if (globalTokenInicialNginx.isEmpty) return;
  headers["Cookie"] = globalTokenInicialNginx;
}

Future<Uint8List> _encryptForServerDart({required String kemPubB64, required String bodyJson, required void Function(String name, String value) setHeader}) async {
  final kemPub = base64.decode(kemPubB64);
  final serverPk = SimplePublicKey(kemPub, type: KeyPairType.x25519);

  final secureRandom = Random.secure();
  final x = DartX25519(random: secureRandom);
  final ephSeed = List<int>.generate(32, (_) => secureRandom.nextInt(256), growable: false);
  final eph = await x.newKeyPairFromSeed(ephSeed);
  final ephPub = await eph.extractPublicKey();
  setHeader('x-epk-b64', base64.encode(ephPub.bytes));

  final shared = await x.sharedSecretKey(keyPair: eph, remotePublicKey: serverPk);

  final aead = DartAesGcm.with256bits();
  final nonce = Uint8List.fromList(List<int>.generate(aead.nonceLength, (_) => secureRandom.nextInt(256), growable: false));
  setHeader('x-iv-b64', base64.encode(nonce));
  setHeader('x-kem', '1');
  setHeader('Content-Type', 'application/octet-stream');

  final hkdf = DartHkdf(hmac: const DartHmac(DartSha256()), outputLength: 32);
  final secret = await hkdf.deriveKey(
    secretKey: shared,
    nonce: nonce, // salt
    info: utf8.encode('sc-aesgcm-v1'),
  );

  final box = await aead.encrypt(utf8.encode(bodyJson), secretKey: secret, nonce: nonce);

  return Uint8List.fromList([...box.cipherText, ...box.mac.bytes]);
}

Future<dynamic> serverPost(String url, {dynamic myJson}) async {
  http.Response response;
  String errorDetail = '';
  String errorCode = '';

  final headers = <String, String>{'Content-Type': 'application/json'};
  headers['Authorization'] = 'Bearer ${globalAcess ?? ''}';
  aplicarHeaderTokenInicialNginx(headers);

  Future<bool> returnErro() async {
    debugPrint(errorDetail);
    debugPrint(errorCode);
    debugPrint(url.substring(urlRust.length));

    return true;
  }

  try {
    myJson ??= {};

    if (_kemPublic != null && _kemPublic!.isNotEmpty) {
      final cipher = await _encryptForServerDart(kemPubB64: _kemPublic!, bodyJson: json.encode(myJson), setHeader: (name, value) => headers[name] = value);

      myJson = cipher;
    } else {
      myJson = json.encode("Erro");

      headers['Content-Type'] = 'application/json';
    }

    final String urlPronta = url.startsWith(urlRust) ? url : '${urlRust.replaceAll(RegExp(r"/+$"), "")}/${url.replaceAll(RegExp(r"^/+"), "")}';

    response = await http.post(Uri.parse(urlPronta), headers: headers, body: myJson);
  } catch (e) {
    errorDetail = 'Erro CORS';
    errorCode = 'Provavelmente seu aplicativo está aberto a muito tempo. Feche tudo e abra novamente.';
    return returnErro();
  }

  final bodyStr = utf8.decode(response.bodyBytes);

  if (bodyStr.contains('ErrorDetail')) {
    final clearBody = bodyStr.replaceFirst('out of range: ', '');
    final err = jsonDecode(clearBody) as Map<String, dynamic>;
    errorDetail = (err['ErrorDetail'] ?? '').toString();
    errorCode = (err['ErrorCode'] ?? '').toString();
    return returnErro();
  } else if (response.statusCode != 200) {
    errorDetail = 'Erro: ${response.statusCode}';
    errorCode = bodyStr;
    return returnErro();
  }

  final tempGlobal = response.headers['global'];
  if (tempGlobal != null) {
    if (tempGlobal.contains(".") || globalAcess == null) {
      globalAcess = tempGlobal;
    }
  }

  final kemB64 = response.headers['kem-public-b64'];
  if (kemB64 != null && kemB64.isNotEmpty) {
    _kemPublic = kemB64;
  }

  return bodyStr;
}
