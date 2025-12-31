import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/localizations.dart';
import '../theme/app_theme.dart';

/// Profile screen where users can view and edit their profile
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      _nameController.text = appState.userProgress.name ?? '';
      _usernameController.text = appState.userProgress.username ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    await appState.updateUserProfile(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final localizations = AppLocalizations(settingsProvider.language);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.profileUpdated),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );
  }

  void _cancelEdit() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    _nameController.text = appState.userProgress.name ?? '';
    _usernameController.text = appState.userProgress.username ?? '';
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final localizations = AppLocalizations(settingsProvider.language);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: localizations.editProfile,
            ),
        ],
      ),
      body: Consumer2<AppStateProvider, AuthProvider>(
        builder: (context, appState, auth, child) {
          final userProgress = appState.userProgress;
          final email = auth.user?.email ?? '';

          // Update controllers when userProgress changes
          if (_nameController.text != (userProgress.name ?? '')) {
            _nameController.text = userProgress.name ?? '';
          }
          if (_usernameController.text != (userProgress.username ?? '')) {
            _usernameController.text = userProgress.username ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile header with avatar
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryPurple,
                                AppTheme.secondaryBlue,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userProgress.name ?? localizations.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            inherit: false,
                            fontWeight: FontWeight.bold,
                            textBaseline: TextBaseline.alphabetic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${userProgress.username ?? 'username'}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            inherit: false,
                            color: theme.colorScheme.onSurfaceVariant,
                            textBaseline: TextBaseline.alphabetic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            inherit: false,
                            color: theme.colorScheme.onSurfaceVariant,
                            textBaseline: TextBaseline.alphabetic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Edit form
                  if (_isEditing) ...[
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: localizations.name,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outlined,
                          color: AppTheme.primaryPurple,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? theme.colorScheme.surface
                            : theme.colorScheme.surfaceContainerHighest,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.nameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: localizations.username,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.alternate_email,
                          color: AppTheme.primaryPurple,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? theme.colorScheme.surface
                            : theme.colorScheme.surfaceContainerHighest,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.usernameRequired;
                        }
                        if (value.length < 3) {
                          return localizations.usernameTooShort;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving ? null : _cancelEdit,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(localizations.cancel),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(localizations.save),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Display mode
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outlined,
                                color: AppTheme.primaryPurple,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                localizations.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  inherit: false,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  textBaseline: TextBaseline.alphabetic,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userProgress.name ?? '-',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              inherit: false,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.alternate_email,
                                color: AppTheme.primaryPurple,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                localizations.username,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  inherit: false,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  textBaseline: TextBaseline.alphabetic,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userProgress.username ?? '-',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              inherit: false,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

