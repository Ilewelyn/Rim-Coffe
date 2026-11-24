import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rim_coffee/core/services/imagen_local.dart';

/// Abre la galería para elegir el logo del negocio. Devuelve la ruta
/// guardada, o null si se canceló o falló.
Future<String?> elegirLogoDeGaleria(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final foto = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 700,
      maxHeight: 700,
      imageQuality: 85,
    );
    if (foto == null) {
      return null;
    }
    return await guardarImagenElegida(foto);
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('No se pudo abrir la galería. Intenta de nuevo.')),
    );
    return null;
  }
}
