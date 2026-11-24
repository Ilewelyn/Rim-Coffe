import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rim_coffee/core/models/negocio.dart';
import 'package:rim_coffee/core/storage/app_storage.dart';
import 'package:rim_coffee/core/utils/seguridad.dart';

/// Cuenta del negocio: registro, inicio de sesión (correo y contraseña o
/// Google), cambio de contraseña y datos que personalizan la app (nombre,
/// eslogan y logo). La sesión se guarda: al volver a abrir la app se entra
/// directo a la pantalla de "¿Quién atiende?".
class NegocioController extends ChangeNotifier {
  NegocioController._();

  static final NegocioController instance = NegocioController._();

  static const String _kNegocio = 'rc.v2.negocio';
  static const String _kSesion = 'rc.v2.sesion';

  /// Nombre de la plataforma (cuando todavía no hay negocio registrado).
  static const String nombreApp = 'Rim Coffee';

  Negocio? negocio;
  bool sesionIniciada = false;
  bool _migrado = false;

  bool get existeCuenta => negocio != null;
  bool get estaAutenticado => negocio != null && sesionIniciada;
  String get nombre => negocio?.nombre ?? nombreApp;
  String get correo => negocio?.correo ?? '';
  String get eslogan {
    final e = negocio?.eslogan ?? '';
    return e.isEmpty ? 'Café de especialidad, servido con calma.' : e;
  }

  String get logo => negocio?.logo ?? '';
  bool get tieneContrasena => negocio?.tieneContrasena ?? false;
  String get correoGoogle => negocio?.correoGoogle ?? '';

  void cargar() {
    final raw = AppStorage.leer(_kNegocio);
    negocio = raw == null
        ? null
        : Negocio.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    sesionIniciada = negocio != null && AppStorage.leer(_kSesion) == 'si';
    _migrado = false;
    final n = negocio;
    // Versión anterior: la contraseña estaba sin cifrar. Se cifra aquí y se
    // guarda después de que los usuarios lean los PIN anteriores.
    if (n != null && !n.tieneContrasena && (n.legacyContrasena ?? '').isNotEmpty) {
      n.sal = Seguridad.nuevaSal();
      n.contrasenaHuella = Seguridad.huella(n.legacyContrasena!, n.sal);
      _migrado = true;
    }
    if (n != null && (n.legacyPinDueno != null || n.legacyPinPersonal != null)) {
      _migrado = true;
    }
  }

  /// Guarda la cuenta si se migró desde la versión anterior.
  void guardarSiMigro() {
    if (_migrado) {
      _guardar();
      _migrado = false;
    }
  }

  void _guardar() {
    final n = negocio;
    if (n == null) {
      AppStorage.borrar(_kNegocio);
    } else {
      AppStorage.escribir(_kNegocio, jsonEncode(n.toJson()));
    }
  }

  void _abrirSesion() {
    sesionIniciada = true;
    AppStorage.escribir(_kSesion, 'si');
    notifyListeners();
  }

  bool correoRegistrado(String correo) {
    final n = negocio;
    final c = correo.trim().toLowerCase();
    return n != null && (n.correo == c || (n.correoGoogle.isNotEmpty && n.correoGoogle == c));
  }

  /// True si el correo y la contraseña son los de la cuenta del negocio.
  bool iniciarSesion(String correo, String contrasena) {
    final n = negocio;
    if (n == null || !correoRegistrado(correo)) {
      return false;
    }
    if (!Seguridad.coincide(contrasena, n.sal, n.contrasenaHuella)) {
      return false;
    }
    _abrirSesion();
    return true;
  }

  /// Entra con una cuenta de Google. Vale si ese correo es el de la cuenta
  /// del negocio o el que se vinculó.
  bool iniciarConGoogle(String correoGoogle) {
    if (!correoRegistrado(correoGoogle)) {
      return false;
    }
    _abrirSesion();
    return true;
  }

  /// Crea la cuenta del negocio (una por dispositivo) e inicia sesión.
  /// Con Google la contraseña es opcional. Devuelve un mensaje de error, o
  /// null si todo salió bien.
  String? registrar({
    required String nombre,
    required String correo,
    String contrasena = '',
    String correoGoogle = '',
    String eslogan = '',
    String logo = '',
  }) {
    if (existeCuenta) {
      return 'Este dispositivo ya tiene una cuenta del negocio. '
          'Inicia sesión o borra los datos desde Panel → Seguridad.';
    }
    if (contrasena.isEmpty && correoGoogle.isEmpty) {
      return 'Escribe una contraseña o continúa con Google.';
    }
    final sal = Seguridad.nuevaSal();
    negocio = Negocio(
      nombre: nombre.trim(),
      correo: correo.trim().toLowerCase(),
      sal: sal,
      contrasenaHuella: contrasena.isEmpty ? '' : Seguridad.huella(contrasena, sal),
      correoGoogle: correoGoogle.trim().toLowerCase(),
      eslogan: eslogan.trim(),
      logo: logo,
    );
    _guardar();
    _abrirSesion();
    return null;
  }

  void cerrarSesion() {
    sesionIniciada = false;
    AppStorage.borrar(_kSesion);
    notifyListeners();
  }

  /// Cambia la contraseña pidiendo la actual (si la cuenta ya tenía una).
  String? cambiarContrasena({required String actual, required String nueva}) {
    final n = negocio;
    if (n == null) {
      return 'No hay cuenta.';
    }
    if (n.tieneContrasena && !Seguridad.coincide(actual, n.sal, n.contrasenaHuella)) {
      return 'La contraseña actual no es correcta.';
    }
    _fijarContrasena(n, nueva);
    return null;
  }

  /// Pone una contraseña nueva después de verificar al beneficiario
  /// (recuperar contraseña). False si el correo no es de la cuenta.
  bool restablecerContrasena(String correo, String nueva) {
    final n = negocio;
    if (n == null || !correoRegistrado(correo)) {
      return false;
    }
    _fijarContrasena(n, nueva);
    return true;
  }

  void _fijarContrasena(Negocio n, String nueva) {
    n.sal = Seguridad.nuevaSal();
    n.contrasenaHuella = Seguridad.huella(nueva, n.sal);
    _guardar();
    notifyListeners();
  }

  /// Vincula una cuenta de Google para poder entrar con ella.
  void vincularGoogle(String correoGoogle) {
    final n = negocio;
    if (n == null) {
      return;
    }
    n.correoGoogle = correoGoogle.trim().toLowerCase();
    _guardar();
    notifyListeners();
  }

  /// Quita la cuenta de Google. Solo si hay contraseña (para no quedarse
  /// sin forma de entrar).
  String? desvincularGoogle() {
    final n = negocio;
    if (n == null) {
      return 'No hay cuenta.';
    }
    if (!n.tieneContrasena) {
      return 'Primero crea una contraseña para no quedarte sin acceso.';
    }
    n.correoGoogle = '';
    _guardar();
    notifyListeners();
    return null;
  }

  void actualizarNombre(String nuevo) {
    actualizarPerfil(nombre: nuevo);
  }

  /// Cambia los datos visibles del negocio. Lo que venga en null no cambia.
  void actualizarPerfil({String? nombre, String? eslogan, String? logo}) {
    final n = negocio;
    if (n == null) {
      return;
    }
    if (nombre != null && nombre.trim().isNotEmpty) {
      n.nombre = nombre.trim();
    }
    if (eslogan != null) {
      n.eslogan = eslogan.trim();
    }
    if (logo != null) {
      n.logo = logo;
    }
    _guardar();
    notifyListeners();
  }

  /// Quita la cuenta (después de borrar los datos del dispositivo).
  void olvidarCuenta() {
    negocio = null;
    sesionIniciada = false;
    AppStorage.borrar(_kNegocio);
    AppStorage.borrar(_kSesion);
    notifyListeners();
  }
}
