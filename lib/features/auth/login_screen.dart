import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_args.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/services/google_auth.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/utils/validadores.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Inicio de sesión de la cuenta del negocio: correo y contraseña, o
/// Google. Después se pide el código de quien atiende.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _clave = TextEditingController();
  String? _error;
  bool _conGoogle = false;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  void _irAlInicio() {
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (ruta) => false);
  }

  void _entrar() {
    setState(() => _error = null);
    final valido = _formulario.currentState?.validate() ?? false;
    if (!valido) {
      return;
    }
    final negocio = NegocioController.instance;
    if (!negocio.existeCuenta) {
      setState(() => _error = 'Todavía no hay un negocio en este dispositivo. Créalo primero.');
      return;
    }
    if (!negocio.iniciarSesion(_correo.text, _clave.text)) {
      setState(() => _error = negocio.tieneContrasena
          ? 'Correo o contraseña incorrectos.'
          : 'Esta cuenta se creó con Google: usa "Continuar con Google".');
      return;
    }
    _irAlInicio();
  }

  Future<void> _entrarConGoogle() async {
    setState(() {
      _error = null;
      _conGoogle = true;
    });
    final r = await GoogleAuth.elegirCuenta();
    if (!mounted) {
      return;
    }
    setState(() => _conGoogle = false);
    final cuenta = r.cuenta;
    if (r.error != null) {
      setState(() => _error = r.error);
      return;
    }
    if (cuenta == null) {
      return;
    }
    final negocio = NegocioController.instance;
    if (!negocio.existeCuenta) {
      Navigator.of(context).pushNamed(
        Routes.registro,
        arguments: RegistroArgs(correoGoogle: cuenta.correo, nombre: cuenta.nombre),
      );
      return;
    }
    if (negocio.iniciarConGoogle(cuenta.correo)) {
      _irAlInicio();
      return;
    }
    setState(() => _error = 'La cuenta ${cuenta.correo} no está vinculada a este negocio. '
        'Entra con correo y contraseña y vincúlala en Panel → Seguridad.');
  }

  @override
  Widget build(BuildContext context) {
    final negocio = NegocioController.instance;
    final existeCuenta = negocio.existeCuenta;
    final alto = MediaQuery.of(context).size.height;
    final altoPortada = (alto * 0.42).clamp(260.0, 420.0).toDouble();

    return Scaffold(
      backgroundColor: AppColors.foam,
      body: Stack(
        children: [
          SizedBox(
            height: altoPortada,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const AppImage(AppAssets.login, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x6624160F), Color(0xF224160F)],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LogoNegocio(tamano: 58, borde: 3),
                        const SizedBox(height: 16),
                        Text(
                          existeCuenta ? negocio.nombre : NegocioController.nombreApp,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.display.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          existeCuenta
                              ? negocio.eslogan
                              : 'El mostrador digital para tu cafetería.',
                          style: const TextStyle(fontSize: 14, color: AppColors.latte),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, altoPortada - 70, 20, 28),
                  child: Column(
                    children: [
                      SoftCard(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                        radius: 28,
                        child: Form(
                          key: _formulario,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                existeCuenta ? 'Bienvenido de nuevo' : 'Comencemos',
                                style: AppText.h2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                existeCuenta
                                    ? 'Entra con la cuenta del negocio. Después cada persona '
                                        'escribe su código para atender.'
                                    : 'Crea tu negocio: menú, mesas y usuarios en un par de minutos.',
                                style: AppText.caption,
                              ),
                              const SizedBox(height: 20),
                              if (GoogleAuth.disponible) ...[
                                BotonGoogle(onPressed: _entrarConGoogle, cargando: _conGoogle),
                                const SizedBox(height: 16),
                                const Row(
                                  children: [
                                    Expanded(child: Divider()),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('o con tu correo', style: AppText.caption),
                                    ),
                                    Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                              RcTextField(
                                label: 'CORREO',
                                controller: _correo,
                                hint: 'nombre@correo.com',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: Validadores.correo,
                                prefixIcon: const Icon(
                                  Icons.mail_outline,
                                  color: AppColors.muted,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 14),
                              RcPasswordField(
                                label: 'CONTRASEÑA',
                                controller: _clave,
                                hint: 'Tu contraseña',
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _entrar(),
                                validator: (v) =>
                                    Validadores.requerido(v, 'Escribe tu contraseña'),
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                AvisoError(_error!),
                              ],
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pushNamed(Routes.recuperar),
                                  child: const Text('¿Olvidaste tu contraseña?'),
                                ),
                              ),
                              RcButton(label: 'Iniciar sesión', onPressed: _entrar),
                              if (!existeCuenta) ...[
                                const SizedBox(height: 10),
                                RcButton(
                                  label: 'Crear mi negocio',
                                  icon: Icons.storefront_outlined,
                                  style: RcButtonStyle.outline,
                                  onPressed: () =>
                                      Navigator.of(context).pushNamed(Routes.registro),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AvisoInfo(
                        existeCuenta
                            ? 'Una cuenta por negocio. El beneficiario ve reportes y ajustes; '
                                'los administradores atienden con su propio código.'
                            : 'Primera vez en este dispositivo: crea tu negocio con Google o '
                                'con correo y contraseña. Después podrás personalizar menú, '
                                'mesas y usuarios.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
