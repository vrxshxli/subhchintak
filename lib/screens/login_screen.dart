import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() { _emailController.dispose(); _passwordController.dispose(); super.dispose(); }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailController.text.trim(), _passwordController.text);
    if (success && mounted) Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (success && mounted) Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 60),
            FadeInDown(duration: const Duration(milliseconds: 600), child: Container(width: 56, height: 56,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight])),
                child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 28))),
            const SizedBox(height: 28),
            FadeInDown(delay: const Duration(milliseconds: 200), child: Text(lang.t('welcome_back'), style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1))),
            const SizedBox(height: 8),
            FadeInDown(delay: const Duration(milliseconds: 300), child: Text(lang.t('sign_in_subtitle'), style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
            const SizedBox(height: 40),
            if (auth.error != null)
              FadeIn(child: Container(width: double.infinity, padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.danger.withOpacity(0.3))),
                  child: Row(children: [const Icon(Icons.error_outline, color: AppColors.danger, size: 20), const SizedBox(width: 10),
                    Expanded(child: Text(auth.error!, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.danger)))]))),
            FadeInUp(delay: const Duration(milliseconds: 400), child: Form(key: _formKey, child: Column(children: [
              TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(hintText: lang.t('email'), prefixIcon: Icon(Icons.email_outlined, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  validator: (v) { if (v == null || v.isEmpty) return '${lang.t('email')} required'; if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Invalid email'; return null; }),
              const SizedBox(height: 16),
              TextFormField(controller: _passwordController, obscureText: _obscurePassword,
                  decoration: InputDecoration(hintText: lang.t('password'), prefixIcon: Icon(Icons.lock_outline, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))),
                  validator: (v) { if (v == null || v.isEmpty) return '${lang.t('password')} required'; if (v.length < 6) return 'Min 6 chars'; return null; }),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {},
                  child: Text(lang.t('forgot_password'), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.accent)))),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleLogin,
                  child: auth.isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(lang.t('sign_in'), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)))),
            ]))),
            const SizedBox(height: 28),
            FadeInUp(delay: const Duration(milliseconds: 500), child: Row(children: [
              Expanded(child: Divider(color: Theme.of(context).dividerColor)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(lang.t('or_continue_with'), style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
              Expanded(child: Divider(color: Theme.of(context).dividerColor)),
            ])),
            const SizedBox(height: 28),
            FadeInUp(delay: const Duration(milliseconds: 600), child: SizedBox(width: double.infinity, height: 56,
                child: OutlinedButton(onPressed: auth.isLoading ? null : _handleGoogleSignIn,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF4285F4))),
                      const SizedBox(width: 12),
                      Text(lang.t('continue_with_google'), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
                    ])))),
            const SizedBox(height: 32),
            FadeInUp(delay: const Duration(milliseconds: 700), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(lang.t('no_account'), style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              GestureDetector(onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                  child: Text(lang.t('sign_up'), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent))),
            ])),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}