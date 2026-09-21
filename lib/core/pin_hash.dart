/// Hash del PIN de bloqueo de la app (Ajustes > Bloqueo de la app).
///
/// El PIN nunca se guarda en claro en la base de datos: solo este hash y
/// la sal aleatoria usada para calcularlo (`AppSettings.appLockPinHash` /
/// `appLockPinSalt`). No hace falta nada mas elaborado (bcrypt/scrypt con
/// coste ajustable, pensado para resistir fuerza bruta remota contra una
/// cuenta online) -- esto protege datos locales de que alguien coja el
/// movil desbloqueado y abra la app, no una cuenta en un servidor. SHA-256
/// con sal es de sobra para eso, y evita anadir una dependencia mas con
/// codigo nativo (`local_auth`, que ya hace falta para la huella/cara, es
/// la unica que de verdad hacia falta para este bloqueo).
library;

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Genera una sal aleatoria nueva (16 bytes, en hexadecimal) para un PIN
/// nuevo. Una sal distinta por instalacion evita que dos personas con el
/// mismo PIN de 4 digitos acaben con exactamente el mismo hash guardado.
String generatePinSalt() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Calcula el hash de `pin` con la `salt` dada (SHA-256 de "salt:pin").
/// Se usa tanto para guardar un PIN nuevo como para comprobar uno
/// introducido contra el hash ya guardado (`SavingsRepository`).
String hashPin(String pin, String salt) {
  return sha256.convert(utf8.encode('$salt:$pin')).toString();
}
