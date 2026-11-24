import 'package:rim_coffee/core/models/linea_carrito.dart';
import 'package:rim_coffee/core/models/producto.dart';

/// Argumentos para la pantalla de detalle de producto.
/// Si [editar] viene lleno, la pantalla actualiza esa línea del carrito.
class DetalleProductoArgs {
  const DetalleProductoArgs({required this.producto, this.editar});

  final Producto producto;
  final LineaCarrito? editar;
}

/// Datos para el registro cuando se viene de "Continuar con Google".
class RegistroArgs {
  const RegistroArgs({required this.correoGoogle, this.nombre = ''});

  final String correoGoogle;
  final String nombre;
}
