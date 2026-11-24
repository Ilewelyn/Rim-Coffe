import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/models/usuario.dart';
import 'package:rim_coffee/core/state/usuarios_controller.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/dueno/salir_panel.dart';
import 'package:rim_coffee/features/shared/usuario_form_sheet.dart';

/// Usuarios (solo beneficiario): alta de beneficiarios y administradores,
/// cada uno con su código; editar nombre, rol y permisos; restablecer
/// códigos olvidados; dar de baja y reactivar.
class UsuariosAdminScreen extends StatelessWidget {
  const UsuariosAdminScreen({super.key});

  void _aviso(BuildContext context, String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _nuevo(BuildContext context) async {
    final ok = await mostrarFormularioUsuario(context);
    if (ok && context.mounted) {
      _aviso(context, 'Usuario dado de alta. Ya puede entrar con su código.');
    }
  }

  Future<void> _opciones(BuildContext context, Usuario u) async {
    final yo = UsuariosController.instance.actual;
    final accion = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: AvatarUsuario(iniciales: u.iniciales, beneficiario: u.esBeneficiario),
                title: Text(u.nombre, style: AppText.h3),
                subtitle: Text(u.rol.nombre, style: AppText.caption),
              ),
              const Divider(),
              if (u.activo) ...[
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Editar nombre, rol y permisos'),
                  onTap: () => Navigator.of(ctx).pop('editar'),
                ),
                ListTile(
                  leading: const Icon(Icons.pin_outlined),
                  title: Text(u.tieneCodigo ? 'Restablecer código' : 'Asignar código'),
                  subtitle: const Text('Si lo olvidó, ponle uno nuevo y díselo en persona.'),
                  onTap: () => Navigator.of(ctx).pop('codigo'),
                ),
                if (u.id != yo?.id)
                  ListTile(
                    leading: const Icon(Icons.person_off_outlined, color: AppColors.danger),
                    title: const Text(
                      'Dar de baja',
                      style: TextStyle(color: AppColors.danger),
                    ),
                    subtitle: const Text('Ya no podrá entrar. Sus ventas siguen en reportes.'),
                    onTap: () => Navigator.of(ctx).pop('baja'),
                  ),
              ] else
                ListTile(
                  leading: const Icon(Icons.person_add_alt_outlined, color: AppColors.ok),
                  title: const Text('Reactivar'),
                  onTap: () => Navigator.of(ctx).pop('reactivar'),
                ),
            ],
          ),
        ),
      ),
    );
    if (accion == null || !context.mounted) {
      return;
    }
    final controlador = UsuariosController.instance;
    switch (accion) {
      case 'editar':
        final editado = await mostrarFormularioUsuario(context, usuario: u);
        if (editado && context.mounted) {
          _aviso(context, 'Cambios guardados');
        }
        break;
      case 'codigo':
        final cambiado = await mostrarCambioCodigo(context, u);
        if (cambiado && context.mounted) {
          _aviso(context, 'Código de ${u.nombre} actualizado');
        }
        break;
      case 'baja':
        final seguro = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('¿Dar de baja a ${u.nombre}?'),
            content: const Text(
              'Ya no podrá entrar ni atender mesas. Sus ventas anteriores se '
              'conservan en los reportes. Puedes reactivarlo después.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                child: const Text('Dar de baja'),
              ),
            ],
          ),
        );
        if (seguro == true && context.mounted) {
          final error = controlador.darDeBaja(u);
          _aviso(context, error ?? '${u.nombre} fue dado de baja');
        }
        break;
      case 'reactivar':
        controlador.reactivar(u);
        _aviso(context, '${u.nombre} está activo otra vez');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlador = UsuariosController.instance;

    return Scaffold(
      appBar: rcAppBar(title: 'Usuarios', actions: [botonSalirPanel(context)]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _nuevo(context),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Nuevo usuario'),
      ),
      body: ListenableBuilder(
        listenable: controlador,
        builder: (context, _) {
          final activos = controlador.activos;
          final beneficiarios = activos.where((u) => u.esBeneficiario).toList();
          final admins = activos.where((u) => !u.esBeneficiario).toList();
          final bajas = controlador.bajas;
          final yo = controlador.actual;

          Widget fila(Usuario u) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _UsuarioTarjeta(
                  usuario: u,
                  esYo: u.id == yo?.id,
                  onTap: () => _opciones(context, u),
                ),
              );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            children: [
              const AvisoInfo(
                'Cada persona entra con su propio código. El beneficiario ve todo; '
                'a los administradores les eliges qué pueden hacer además de atender.',
                icono: Icons.verified_user_outlined,
              ),
              const SizedBox(height: 18),
              SectionTitle(
                'Beneficiarios',
                trailing: Text('${beneficiarios.length}', style: AppText.caption),
              ),
              const SizedBox(height: 10),
              for (final u in beneficiarios) fila(u),
              const SizedBox(height: 10),
              SectionTitle(
                'Administradores',
                trailing: Text('${admins.length}', style: AppText.caption),
              ),
              const SizedBox(height: 10),
              if (admins.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Todavía no hay administradores. Toca "Nuevo usuario" para dar de alta '
                    'a quien atiende el mostrador.',
                    style: AppText.caption,
                  ),
                )
              else
                for (final u in admins) fila(u),
              if (bajas.isNotEmpty) ...[
                const SizedBox(height: 10),
                SectionTitle(
                  'Dados de baja',
                  trailing: Text('${bajas.length}', style: AppText.caption),
                ),
                const SizedBox(height: 10),
                for (final u in bajas) fila(u),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _UsuarioTarjeta extends StatelessWidget {
  const _UsuarioTarjeta({required this.usuario, required this.esYo, required this.onTap});

  final Usuario usuario;
  final bool esYo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final u = usuario;
    final permisos = u.esBeneficiario
        ? 'Acceso total'
        : (u.permisos.isEmpty
            ? 'Solo atiende mesas y pedidos'
            : Permiso.values.where(u.permisos.contains).map((p) => p.nombre).join(' · '));

    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: [
          AvatarUsuario(
            iniciales: u.iniciales,
            beneficiario: u.esBeneficiario,
            apagado: !u.activo,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        u.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.title,
                      ),
                    ),
                    if (esYo) ...[
                      const SizedBox(width: 6),
                      const StatusChip(
                        label: 'Tú',
                        fondo: AppColors.crema,
                        texto: AppColors.cafe,
                      ),
                    ],
                    if (!u.tieneCodigo && u.activo) ...[
                      const SizedBox(width: 6),
                      const StatusChip(
                        label: 'Sin código',
                        fondo: Color(0xFFFFEBD0),
                        texto: Color(0xFF9A5B13),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  permisos,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.muted),
        ],
      ),
    );
  }
}
