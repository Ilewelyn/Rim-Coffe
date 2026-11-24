import 'package:flutter/material.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/widgets/app_image.dart';

/// Logo del negocio dentro de un círculo blanco. Usa la foto que eligió el
/// beneficiario (Panel → Negocio) o, si no hay, el logo por defecto.
class LogoNegocio extends StatelessWidget {
  const LogoNegocio({super.key, this.tamano = 54, this.borde = 4, this.sombra = false});

  final double tamano;
  final double borde;
  final bool sombra;

  @override
  Widget build(BuildContext context) {
    final negocio = NegocioController.instance;
    return ListenableBuilder(
      listenable: negocio,
      builder: (context, _) {
        final ruta = negocio.logo.isEmpty ? AppAssets.logo : negocio.logo;
        return Container(
          padding: EdgeInsets.all(borde),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: sombra
                ? const [
                    BoxShadow(color: Color(0x55000000), blurRadius: 28, offset: Offset(0, 12)),
                  ]
                : null,
          ),
          child: AppImage(ruta, width: tamano, height: tamano, radius: tamano / 2),
        );
      },
    );
  }
}
