import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Cuenta de Google elegida por el usuario.
class CuentaGoogle {
  const CuentaGoogle({required this.correo, required this.nombre});

  final String correo;
  final String nombre;
}

/// Resultado de "Continuar con Google": la cuenta elegida, un mensaje de
/// error, o ninguno de los dos si el usuario canceló.
class ResultadoGoogle {
  const ResultadoGoogle({this.cuenta, this.error});

  final CuentaGoogle? cuenta;
  final String? error;
}

/// Inicio de sesión con Google (solo se usa para saber qué correo es el
/// del usuario; los datos siguen guardados en el dispositivo).
///
/// Para que funcione hay que registrar la app en Google Cloud con su
/// nombre de paquete y su huella SHA-1 (ver GOOGLE_LOGIN.md). Si no está
/// configurado, se muestra un mensaje claro y se puede seguir usando
/// correo y contraseña.
class GoogleAuth {
  GoogleAuth._();

  /// En la versión web no se ofrece (necesita otra configuración).
  static bool get disponible => !kIsWeb;

  static final GoogleSignIn _google = GoogleSignIn(scopes: const ['email']);

  static Future<ResultadoGoogle> elegirCuenta() async {
    if (!disponible) {
      return const ResultadoGoogle(
        error: 'El inicio con Google solo está disponible en la app de Android.',
      );
    }
    try {
      // Cierra la sesión anterior para que siempre pregunte qué cuenta usar.
      await _google.signOut();
    } catch (_) {
      // No había sesión: no importa.
    }
    try {
      final cuenta = await _google.signIn();
      if (cuenta == null) {
        return const ResultadoGoogle();
      }
      return ResultadoGoogle(
        cuenta: CuentaGoogle(
          correo: cuenta.email.trim().toLowerCase(),
          nombre: cuenta.displayName ?? '',
        ),
      );
    } on PlatformException catch (e) {
      return ResultadoGoogle(error: _mensaje('${e.code} ${e.message ?? ''}'));
    } catch (e) {
      return ResultadoGoogle(error: _mensaje(e.toString()));
    }
  }

  static String _mensaje(String detalle) {
    final sinConfigurar = RegExp(r'ApiException:\s*(10|12500)\b').hasMatch(detalle) ||
        detalle.contains('DEVELOPER_ERROR');
    if (sinConfigurar) {
      return 'El inicio con Google todavía no está configurado para esta app. '
          'Usa tu correo y contraseña (el responsable puede activarlo con la '
          'guía GOOGLE_LOGIN.md).';
    }
    if (detalle.contains('network_error') || detalle.contains('ApiException: 7')) {
      return 'Sin conexión a internet. Revisa la red e inténtalo de nuevo.';
    }
    return 'No se pudo iniciar con Google. Inténtalo de nuevo o usa tu correo.';
  }
}
