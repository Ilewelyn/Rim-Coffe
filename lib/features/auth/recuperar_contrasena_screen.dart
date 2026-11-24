import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/services/google_auth.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/state/usuarios_controller.dart';
import 'package:rim_coffee/core/utils/validadores.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

enum _Paso { correo, verificar, nueva, listo }

/// Olvidé mi contraseña. Como los datos viven en el dispositivo, para
/// demostrar que eres el dueño de la cuenta se pide el código de un
/// beneficiario (o la cuenta de Google vinculada). Después se crea una
/// contraseña nueva.
class RecuperarContrasenaScreen extends StatefulWidget {
  const RecuperarContrasenaScreen({super.key});

  @override
  State<RecuperarContrasenaScreen> createState() => _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState extends State<RecuperarContrasenaScreen> {
  final GlobalKey<FormState> _formCorreo = GlobalKey<FormState>();
  final GlobalKey<FormState> _formClave = GlobalKey<FormState>();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _clave = TextEditingController();
  final TextEditingController _confirmar = TextEditingController();
  _Paso _paso = _Paso.correo;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  void _continuar() {
    setState(() => _error = null);
    if (!(_formCorreo.currentState?.validate() ?? false)) {
      return;
    }
    if (!NegocioController.instance.correoRegistrado(_correo.text)) {
      setState(() => _error = 'No encontramos un negocio con ese correo en este dispositivo.');
      return;
    }
    setState(() => _paso = _Paso.verificar);
  }

  String? _validarCodigo(String codigo) {
    final usuarios = UsuariosController.instance;
    final v = usuarios.verificar(codigo, soloBeneficiario: true);
    if (v.resultado == ResultadoPin.correcto) {
      setState(() => _paso = _Paso.nueva);
      return null;
    }
    if (v.resultado == ResultadoPin.sinPermiso) {
      return 'Ese código no es de un beneficiario.';
    }
    if (v.resultado == ResultadoPin.incorrecto) {
      return 'Código incorrecto · intentos restantes: ${usuarios.intentosRestantes}';
    }
    return null;
  }

  Future<void> _verificarConGoogle() async {
    setState(() => _error = null);
    final r = await GoogleAuth.elegirCuenta();
    if (!mounted) {
      return;
    }
    final cuenta = r.cuenta;
    if (r.error != null) {
      setState(() => _error = r.error);
      return;
    }
    if (cuenta == null) {
      return;
    }
    if (cuenta.correo == NegocioController.instance.correoGoogle) {
      setState(() => _paso = _Paso.nueva);
    } else {
      setState(() => _error = 'Esa cuenta de Google no está vinculada a este negocio.');
    }
  }

  void _guardarNueva() {
    if (!(_formClave.currentState?.validate() ?? false)) {
      return;
    }
    final ok = NegocioController.instance.restablecerContrasena(_correo.text, _clave.text);
    if (!ok) {
      setState(() => _error = 'No pudimos actualizar la contraseña.');
      return;
    }
    setState(() => _paso = _Paso.listo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rcAppBar(title: 'Recuperar contraseña', showBack: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              child: switch (_paso) {
                _Paso.correo => _pasoCorreo(),
                _Paso.verificar => _pasoVerificar(),
                _Paso.nueva => _pasoNueva(),
                _Paso.listo => _pasoListo(),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _encabezado(String titulo, String texto) {
    return Column(
      children: [
        const Center(
          child: AppImage(AppAssets.recuperar, width: 140, height: 140, radius: 70),
        ),
        const SizedBox(height: 18),
        Text(titulo, textAlign: TextAlign.center, style: AppText.h2),
        const SizedBox(height: 6),
        Text(texto, textAlign: TextAlign.center, style: AppText.caption),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _pasoCorreo() {
    return Form(
      key: _formCorreo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _encabezado(
            '¿Olvidaste tu contraseña?',
            'Escribe el correo del negocio. Después confirmarás que eres el '
                'beneficiario con tu código.',
          ),
          RcTextField(
            label: 'CORREO',
            controller: _correo,
            hint: 'nombre@correo.com',
            keyboardType: TextInputType.emailAddress,
            validator: Validadores.correo,
            prefixIcon: const Icon(Icons.mail_outline, color: AppColors.muted, size: 20),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            AvisoError(_error!),
          ],
          const SizedBox(height: 20),
          RcButton(label: 'Continuar', onPressed: _continuar),
        ],
      ),
    );
  }

  Widget _pasoVerificar() {
    final tieneGoogle = NegocioController.instance.correoGoogle.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Text('Confirma que eres el beneficiario', textAlign: TextAlign.center, style: AppText.h2),
        const SizedBox(height: 6),
        const Text(
          'Escribe tu código de beneficiario.',
          textAlign: TextAlign.center,
          style: AppText.caption,
        ),
        const SizedBox(height: 18),
        Center(child: TecladoCodigo(onEnviar: _validarCodigo)),
        if (tieneGoogle && GoogleAuth.disponible) ...[
          const SizedBox(height: 18),
          BotonGoogle(
            texto: 'Verificar con Google',
            onPressed: _verificarConGoogle,
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          AvisoError(_error!),
        ],
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() {
            _error = null;
            _paso = _Paso.correo;
          }),
          child: const Text('Usar otro correo'),
        ),
      ],
    );
  }

  Widget _pasoNueva() {
    return Form(
      key: _formClave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _encabezado('Crea tu nueva contraseña', 'Mínimo 6 caracteres, con letras y números.'),
          RcPasswordField(
            label: 'NUEVA CONTRASEÑA',
            controller: _clave,
            validator: Validadores.contrasena,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          RcPasswordField(
            label: 'CONFIRMAR CONTRASEÑA',
            controller: _confirmar,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (v != _clave.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            AvisoError(_error!),
          ],
          const SizedBox(height: 20),
          RcButton(label: 'Guardar contraseña', onPressed: _guardarNueva),
        ],
      ),
    );
  }

  Widget _pasoListo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _encabezado(
          '¡Contraseña actualizada!',
          'Ya puedes iniciar sesión con tu nueva contraseña.',
        ),
        RcButton(
          label: 'Volver al acceso',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
