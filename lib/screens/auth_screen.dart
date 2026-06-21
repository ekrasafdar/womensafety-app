import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme.dart';
import '../data/app_state.dart';

enum AuthMode { login, signup, forgot }

class AuthScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onAuthenticated;
  const AuthScreen({super.key, required this.state, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  AuthMode _mode = AuthMode.login;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _error;
  String? _info;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode m) {
    setState(() {
      _mode = m;
      _error = null;
      _info = null;
    });
    _fadeController
      ..reset()
      ..forward();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _info = null;
    });

    if (emailCtrl.text.trim().isEmpty || !emailCtrl.text.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }

    if (_mode == AuthMode.forgot) {
      setState(() => _loading = true);
      await Future.delayed(const Duration(milliseconds: 700));
      final err = widget.state.resetPassword(email: emailCtrl.text);
      setState(() {
        _loading = false;
        if (err != null) {
          _error = err;
        } else {
          _info = 'Password reset link sent to ${emailCtrl.text.trim()} (simulated).';
        }
      });
      return;
    }

    if (passCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    if (_mode == AuthMode.signup) {
      if (nameCtrl.text.trim().isEmpty) {
        setState(() => _error = 'Enter your full name.');
        return;
      }
      if (passCtrl.text != confirmCtrl.text) {
        setState(() => _error = 'Passwords do not match.');
        return;
      }
      setState(() => _loading = true);
      await Future.delayed(const Duration(milliseconds: 700));
      final err = widget.state.signUp(name: nameCtrl.text, email: emailCtrl.text, password: passCtrl.text);
      setState(() => _loading = false);
      if (err != null) {
        setState(() => _error = err);
      } else {
        widget.onAuthenticated();
      }
      return;
    }

    // login
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    final err = widget.state.logIn(email: emailCtrl.text, password: passCtrl.text);
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
    } else {
      widget.onAuthenticated();
    }
  }

  void _fillDemo() {
    emailCtrl.text = 'demo@safeguard.app';
    passCtrl.text = 'demo1234';
  }

  String get _title {
    switch (_mode) {
      case AuthMode.login:
        return 'Welcome back';
      case AuthMode.signup:
        return 'Create your account';
      case AuthMode.forgot:
        return 'Reset your password';
    }
  }

  String get _subtitle {
    switch (_mode) {
      case AuthMode.login:
        return 'Sign in to stay protected';
      case AuthMode.signup:
        return 'Join SafeGuard in seconds';
      case AuthMode.forgot:
        return "We'll send you a reset link";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // decorative glow
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppColors.primary.withOpacity(0.25), Colors.transparent],
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 28),
                      Text(_title,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2)),
                      const SizedBox(height: 6),
                      Text(_subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      const SizedBox(height: 32),

                      if (_mode == AuthMode.signup) ...[
                        _label('Full name'),
                        TextField(
                          controller: nameCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Ayesha Khan',
                            prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      _label('Email'),
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.textSecondary),
                        ),
                      ),

                      if (_mode != AuthMode.forgot) ...[
                        const SizedBox(height: 16),
                        _label('Password'),
                        TextField(
                          controller: passCtrl,
                          obscureText: _obscure,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                      ],

                      if (_mode == AuthMode.signup) ...[
                        const SizedBox(height: 16),
                        _label('Confirm password'),
                        TextField(
                          controller: confirmCtrl,
                          obscureText: _obscure,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                          ),
                        ),
                      ],

                      if (_mode == AuthMode.login) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _switchMode(AuthMode.forgot),
                            child: const Text('Forgot password?',
                                style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],

                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        _MessageBanner(text: _error!, color: AppColors.danger, icon: Icons.error_outline_rounded),
                      ],
                      if (_info != null) ...[
                        const SizedBox(height: 8),
                        _MessageBanner(text: _info!, color: AppColors.success, icon: Icons.check_circle_outline_rounded),
                      ],

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                                )
                              : Text(
                                  _mode == AuthMode.login
                                      ? 'Log In'
                                      : _mode == AuthMode.signup
                                          ? 'Create Account'
                                          : 'Send Reset Link',
                                ),
                        ),
                      ),

                      if (_mode == AuthMode.login) ...[
                        const SizedBox(height: 14),
                        Center(
                          child: TextButton.icon(
                            onPressed: _fillDemo,
                            icon: const Icon(Icons.bolt_rounded, size: 18, color: AppColors.textSecondary),
                            label: const Text('Use demo account', style: TextStyle(color: AppColors.textSecondary)),
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),
                      Center(
                        child: _mode == AuthMode.forgot
                            ? TextButton(
                                onPressed: () => _switchMode(AuthMode.login),
                                child: const Text('Back to log in',
                                    style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                              )
                            : RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: _mode == AuthMode.login
                                          ? "Don't have an account? "
                                          : 'Already have an account? ',
                                    ),
                                    TextSpan(
                                      text: _mode == AuthMode.login ? 'Sign up' : 'Log in',
                                      style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _switchMode(
                                            _mode == AuthMode.login ? AuthMode.signup : AuthMode.login),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
      );
}

class _MessageBanner extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const _MessageBanner({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13))),
        ],
      ),
    );
  }
}

