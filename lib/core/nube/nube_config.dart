/// Datos públicos del proyecto de Supabase (rim-coffee).
///
/// La llave "anon" es pública por diseño: la seguridad la dan las reglas
/// RLS de cada tabla (cada negocio solo ve sus propias filas).
class NubeConfig {
  NubeConfig._();

  static const String url = 'https://xnacwcvgjqzplwmuybgh.supabase.co';

  static const String llaveAnon =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhuYWN3Y3ZnanF6cGx3bXV5YmdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTU2MjIxNzcsImV4cCI6MjExMTE5ODE3N30.O4tdyvF-uP2DrPZbxWILqB9L-wKipU3Sutvx2oSDLD4';

  /// ID de cliente de Google tipo "Aplicación web" (Google Cloud). Hace
  /// falta para entrar con Google a la nube. Vacío = Google desactivado.
  static const String googleWebClientId =
      '1097443644220-7oc5ibnfc4ngue22k7b31a2ipohdpuk1.apps.googleusercontent.com';
}
