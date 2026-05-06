import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/admin/admin_service.dart';
import 'package:gestor_personajes_dnd/models/admin/user_dto.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _service = AdminService();
  List<UserDto> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _users = await _service.getAllUsers();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: const BackButton(color: AppTheme.textPrimary),
        title: Text('User Management',
          style: GoogleFonts.cinzel(
            color: AppTheme.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        icon: const Icon(Icons.person_add),
        label: Text('New User',
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : _users.isEmpty
                  ? _EmptyView(onCreateTap: () => _showCreateDialog(context))
                  : RefreshIndicator(
                      color: AppTheme.primary,
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                        itemCount: _users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _UserTile(
                          user: _users[i],
                          service: _service,
                          onChanged: _load,
                        ),
                      ),
                    ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _CreateUserDialog(
        service: _service,
        onCreated: _load,
      ),
    );
  }
}

// -- User tile

class _UserTile extends StatelessWidget {
  final UserDto user;
  final AdminService service;
  final VoidCallback onChanged;
  const _UserTile({
    required this.user,
    required this.service,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: user.active
              ? AppTheme.surfaceVariant
              : AppTheme.accent.withOpacity(0.4),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: user.isAdmin
              ? AppTheme.primary.withOpacity(0.2)
              : AppTheme.surfaceVariant,
          child: Icon(
            user.isAdmin ? Icons.shield : Icons.person,
            color: user.isAdmin ? AppTheme.primary : AppTheme.textSecondary,
            size: 20,
          ),
        ),
        title: Row(children: [
          Text(user.username,
              style: GoogleFonts.cinzel(
                color: user.active ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          if (!user.active)
            _Badge('INACTIVE', AppTheme.accent),
          if (user.isAdmin)
            _Badge('ADMIN', AppTheme.primary),
        ]),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '${user.characterCount}/10 characters'
            '${user.lastLogin != null ? '  ·  Last login: ${_formatDate(user.lastLogin!)}' : ''}',
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 10),
          ),
        ]),
        trailing: _UserMenu(user: user, service: service, onChanged: onChanged),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) { return iso; }
  }
}


// -- User context menu

class _UserMenu extends StatelessWidget {
  final UserDto user;
  final AdminService service;
  final VoidCallback onChanged;
  const _UserMenu({required this.user, required this.service, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
      color: AppTheme.surface,
      onSelected: (v) => _onAction(context, v),
      itemBuilder: (_) => [
        if (user.active)
          const PopupMenuItem(value: 'deactivate', child: _MenuItem(Icons.block, 'Deactivate'))
        else
          const PopupMenuItem(value: 'activate',   child: _MenuItem(Icons.check_circle_outline, 'Activate')),
        const PopupMenuItem(value: 'reset_pw',  child: _MenuItem(Icons.lock_reset, 'Reset password')),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: _MenuItem(Icons.delete_outline, 'Delete', color: Colors.redAccent)),
      ],
    );
  }

  Future<void> _onAction(BuildContext context, String action) async {
    switch (action) {
      case 'activate':
      case 'deactivate':
        try {
          await service.setActive(user.id, action == 'activate');
          onChanged();
        } catch (e) {
          _snack(context, e.toString(), error: true);
        }
        break;

      case 'reset_pw':
        _showResetPasswordDialog(context);
        break;

      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Delete ${user.username}?',
                style: GoogleFonts.cinzel(color: AppTheme.accent)),
            content: Text(
              'This will permanently delete the user and all their characters.',
              style: GoogleFonts.lato(color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel',
                      style: GoogleFonts.lato(color: AppTheme.textSecondary))),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white),
                  child: const Text('Delete')),
            ],
          ),
        );
        if (confirm == true) {
          try {
            await service.deleteUser(user.id);
            onChanged();
          } catch (e) {
            if (context.mounted) _snack(context, e.toString(), error: true);
          }
        }
        break;
    }
  }

  void _showResetPasswordDialog(BuildContext ctx) {
    final ctrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reset password — ${user.username}',
            style: GoogleFonts.cinzel(color: AppTheme.primary, fontSize: 14)),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          style: GoogleFonts.lato(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            labelText: 'New password (min. 6 chars)',
            labelStyle: GoogleFonts.lato(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.surfaceVariant,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_),
              child: Text('Cancel',
                  style: GoogleFonts.lato(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.length < 6) return;
              Navigator.pop(_);
              try {
                await service.resetPassword(user.id, ctrl.text);
                _snack(ctx, 'Password reset for ${user.username}');
              } catch (e) {
                if (ctx.mounted) _snack(ctx, e.toString(), error: true);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext ctx, String msg, {bool error = false}) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppTheme.accent : AppTheme.primary,
      duration: const Duration(seconds: 3),
    ));
  }
}

// -- Create user dialog
class _CreateUserDialog extends StatefulWidget {
  final AdminService service;
  final VoidCallback onCreated;
  const _CreateUserDialog({required this.service, required this.onCreated});

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _formKey    = GlobalKey<FormState>();
  final _userCtrl   = TextEditingController();
  final _pwCtrl     = TextEditingController();
  bool _obscure     = true;
  bool _saving      = false;
  String _role      = 'USER';
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      title: Text('Create New User',
          style: GoogleFonts.cinzel(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 15)),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _Field(ctrl: _userCtrl,  label: 'Username',
              icon: Icons.person_outline,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 3) return 'Min. 3 characters';
                if (v.trim().length > 20) return 'Max. 20 characters';
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim()))
                  return 'Only letters, numbers and underscores';
                return null;
              }),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pwCtrl,
            obscureText: _obscure,
            style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: GoogleFonts.lato(color: AppTheme.textSecondary),
              prefixIcon: const Icon(Icons.lock_outline,
                  color: AppTheme.textSecondary, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.textSecondary, size: 18),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              filled: true,
              fillColor: AppTheme.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
            validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 6) return 'Min. 6 characters';
                if (v.length > 64) return 'Max. 64 characters';
                return null;
              },
          ),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _RoleChip(
              label: 'User',
              selected: _role == 'USER',
              onTap: () => setState(() => _role = 'USER'),
            ),
            const SizedBox(width: 8),
            _RoleChip(
              label: 'Admin',
              selected: _role == 'ADMIN',
              onTap: () => setState(() => _role = 'ADMIN'),
            ),
          ]),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: GoogleFonts.lato(
                    color: AppTheme.accent, fontSize: 11)),
          ],
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.lato(color: AppTheme.textSecondary))),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.background),
          child: _saving
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text('Create',
                  style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      await widget.service.createUser(
        username: _userCtrl.text.trim(),
        password: _pwCtrl.text,
        role: _role,
      );
      if (mounted) Navigator.pop(context);
      widget.onCreated();
    } catch (e) {
      setState(() {
        _error  = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }
}

// -- Change Password Screen (para cualquier usuario)

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _curCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confCtrl = TextEditingController();
  final _service = AdminService();
  bool _saving = false;
  String? _error;
  bool _obscureCur = true;
  bool _obscureNew = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: const BackButton(color: AppTheme.textPrimary),
        title: Text('Change Password',
          style: GoogleFonts.cinzel(
            color: AppTheme.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(children: [
            const SizedBox(height: 16),
          _PwField(
            ctrl: _curCtrl, label: 'Current password',
            obscure: _obscureCur,
            onToggle: () => setState(() => _obscureCur = !_obscureCur),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 16),
            _PwField(
              ctrl: _newCtrl, label: 'New Password',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Min. 6 characters' : null,
            ),
            const SizedBox(height: 16),
            _PwField(
              ctrl: _confCtrl, label: 'Confirm New Password',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              validator: (v) =>
                  v != _newCtrl.text ? 'Passwords do not match' : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!,
                    style: GoogleFonts.lato(
                        color: AppTheme.accent, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Update Password',
                        style: GoogleFonts.cinzel(
                            fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      await _service.changeOwnPassword(
        currentPassword: _curCtrl.text,
        newPassword:     _newCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: AppTheme.primary,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error  = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }
}

// --Widgets auxliaries
class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RoleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? AppTheme.primary : AppTheme.divider,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Text(label,
        style: GoogleFonts.lato(
          color: selected ? AppTheme.primary : AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        )),
    ),
  );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(label,
      style: GoogleFonts.lato(
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5)),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MenuItem(this.icon, this.label, {this.color = AppTheme.textPrimary});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon (icon, color: color, size: 18),
    const SizedBox(width: 10),
    Text(label,
        style: GoogleFonts.lato(color: color, fontSize: 13)),
  ]);
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.lato(color: AppTheme.textSecondary),
      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
      filled: true,
      fillColor: AppTheme.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none),
    ),
    validator: validator,
  );
}

class _PwField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  const _PwField({
    required this.ctrl,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });
  
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    obscureText: obscure,
    style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.lato(color: AppTheme.textSecondary),
      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary, size: 18),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary, size: 18),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: AppTheme.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none),
    ),
    validator: validator,
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, color: AppTheme.accent, size: 48),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.background),
            ),
          ]),
        ),
      );
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyView({required this.onCreateTap});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.group_outlined,
              color: AppTheme.surfaceVariant, size: 52),
          const SizedBox(height: 16),
          Text('No users yet',
              style: GoogleFonts.cinzel(
                  color: AppTheme.textSecondary, fontSize: 15)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.person_add, color: AppTheme.primary),
            label: Text('Create first user',
                style: GoogleFonts.lato(color: AppTheme.primary)),
          ),
        ]),
      );
}

