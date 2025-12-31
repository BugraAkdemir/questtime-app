import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/app_state_provider.dart';
import '../utils/localizations.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';

/// Authentication screen (Login/Signup)
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final localizations = AppLocalizations(settingsProvider.language);

    final success = _isLogin
        ? await authProvider.signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          )
        : await authProvider.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

    if (!mounted) return;

    if (success) {
      // If signup, save name and username
      if (!_isLogin) {
        await appStateProvider.updateUserProfile(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
        );
      }
      // Reload data from Firebase after login/signup
      await appStateProvider.reloadFromFirebase();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin
                ? localizations.welcomeBack
                : localizations.welcome,
          ),
          backgroundColor: AppTheme.primaryPurple,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final localizations = AppLocalizations(settingsProvider.language);
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Skip button (top right)
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: Text(
                        localizations.skip,
                        style: TextStyle(
                          color: AppTheme.primaryPurple,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Logo/Icon with gradient background
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryPurple.withValues(alpha: 0.2),
                          AppTheme.secondaryBlue.withValues(alpha: 0.15),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      size: 64,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    localizations.appTitle,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isLogin
                        ? localizations.welcomeBack
                        : localizations.createAccount,
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Name field (only for signup)
                  if (!_isLogin)
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
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outlined,
                          color: AppTheme.primaryPurple,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.primaryPurple,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? theme.colorScheme.surface
                            : theme.colorScheme.surfaceContainerHighest,
                      ),
                      validator: (value) {
                        if (!_isLogin && (value == null || value.isEmpty)) {
                          return localizations.nameRequired;
                        }
                        return null;
                      },
                    ),
                  if (!_isLogin) const SizedBox(height: 20),
                  // Username field (only for signup)
                  if (!_isLogin)
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
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        prefixIcon: Icon(
                          Icons.alternate_email,
                          color: AppTheme.primaryPurple,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.primaryPurple,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? theme.colorScheme.surface
                            : theme.colorScheme.surfaceContainerHighest,
                      ),
                      validator: (value) {
                        if (!_isLogin) {
                          if (value == null || value.isEmpty) {
                            return localizations.usernameRequired;
                          }
                          if (value.length < 3) {
                            return localizations.usernameTooShort;
                          }
                        }
                        return null;
                      },
                    ),
                  if (!_isLogin) const SizedBox(height: 20),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: localizations.email,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppTheme.primaryPurple,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppTheme.primaryPurple,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? theme.colorScheme.surface
                          : theme.colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.emailRequired;
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return localizations.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: localizations.password,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: AppTheme.primaryPurple,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppTheme.primaryPurple,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? theme.colorScheme.surface
                          : theme.colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.passwordRequired;
                      }
                      if (value.length < 6) {
                        return localizations.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Confirm password field (only for signup)
                  if (!_isLogin)
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: localizations.confirmPassword,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: AppTheme.primaryPurple,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.primaryPurple,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? theme.colorScheme.surface
                            : theme.colorScheme.surfaceContainerHighest,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.passwordRequired;
                        }
                        if (value != _passwordController.text) {
                          return localizations.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                  if (!_isLogin) const SizedBox(height: 20),
                  // Submit button
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _isLogin
                                ? localizations.loginButton
                                : localizations.signUpButton,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),
                  // Toggle between login and signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? localizations.dontHaveAccount
                            : localizations.alreadyHaveAccount,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _formKey.currentState?.reset();
                          });
                        },
                        child: Text(
                          _isLogin
                              ? localizations.signUpHere
                              : localizations.loginHere,
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
