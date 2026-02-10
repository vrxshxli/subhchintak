import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;

  // All screens for debug navigation
  final List<Map<String, dynamic>> _allScreens = [
    {'name': 'Splash', 'route': '/', 'icon': Icons.flash_on_rounded, 'color': Color(0xFFFF6B35)},
    {'name': 'Onboarding', 'route': '/onboarding', 'icon': Icons.swipe_rounded, 'color': Color(0xFF3498DB)},
    {'name': 'Login', 'route': '/login', 'icon': Icons.login_rounded, 'color': Color(0xFF2ECC71)},
    {'name': 'Register', 'route': '/register', 'icon': Icons.person_add_rounded, 'color': Color(0xFF9B59B6)},
    {'name': 'Dashboard', 'route': '/dashboard', 'icon': Icons.dashboard_rounded, 'color': Color(0xFF1ABC9C)},
    {'name': 'Order QR', 'route': '/order-qr', 'icon': Icons.shopping_cart_rounded, 'color': Color(0xFFE74C3C)},
    {'name': 'Design QR Entry', 'route': '/design-qr-entry', 'icon': Icons.design_services_rounded, 'color': Color(0xFFF39C12)},
    {'name': 'QR Templates', 'route': '/design-qr-templates', 'icon': Icons.grid_view_rounded, 'color': Color(0xFF8E44AD)},
    {'name': 'QR Canvas', 'route': '/qr-canvas', 'icon': Icons.brush_rounded, 'color': Color(0xFF2980B9)},
    {'name': 'Payment', 'route': '/payment', 'icon': Icons.payment_rounded, 'color': Color(0xFF27AE60)},
    {'name': 'Emergency Contacts', 'route': '/emergency-contacts', 'icon': Icons.emergency_rounded, 'color': Color(0xFFC0392B)},
    {'name': 'Chat Interface', 'route': '/chat', 'icon': Icons.chat_bubble_rounded, 'color': Color(0xFF16A085)},
    {'name': 'Tag Details', 'route': '/tag-details', 'icon': Icons.local_offer_rounded, 'color': Color(0xFFD35400)},
    {'name': 'Updates', 'route': '/updates', 'icon': Icons.notifications_rounded, 'color': Color(0xFF2C3E50)},
    {'name': 'Profile', 'route': '/profile', 'icon': Icons.person_rounded, 'color': Color(0xFF7F8C8D)},
    {'name': 'Incoming Call', 'route': '/incoming-call', 'icon': Icons.call_received_rounded, 'color': Color(0xFF1B2838)},
    {'name': 'Live Call', 'route': '/live-call', 'icon': Icons.call_rounded, 'color': Color(0xFF2ECC71)},
    {'name': 'Missed Call', 'route': '/missed-call', 'icon': Icons.phone_missed_rounded, 'color': Color(0xFFE74C3C)},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms & conditions')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _phoneController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  void _openDebugDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.accent.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.bug_report_rounded, color: AppColors.accent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Debug Navigator',
                            style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('Navigate to any screen (no auth)',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
              // Screen list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _allScreens.length,
                  itemBuilder: (context, index) {
                    final screen = _allScreens[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDark ? AppColors.darkBg : AppColors.lightBg,
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: (screen['color'] as Color).withOpacity(0.1),
                          ),
                          child: Icon(screen['icon'] as IconData,
                              color: screen['color'] as Color, size: 20),
                        ),
                        title: Text(screen['name'] as String,
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(screen['route'] as String,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onTap: () {
                          Navigator.pop(ctx); // close bottom sheet
                          Navigator.pushNamed(context, screen['route'] as String);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Top row: Back button + Hamburger menu
              FadeInDown(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                          ),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, size: 20),
                      ),
                    ),
                    // DEBUG HAMBURGER MENU
                    GestureDetector(
                      onTap: _openDebugDrawer,
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, AppColors.accentLight],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.menu_rounded, size: 22, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Create Account',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Start protecting your belongings today',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (auth.error != null)
                FadeIn(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(auth.error!,
                              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.danger)),
                        ),
                      ],
                    ),
                  ),
                ),
              // Form
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email address',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Phone number',
                          prefixIcon: Icon(Icons.phone_outlined,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          prefixText: '+91 ',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Phone is required';
                          if (v.length < 10) return 'Enter a valid phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 6) return 'Min 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outline,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: (v) {
                          if (v != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Terms
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreeTerms,
                              onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                              activeColor: AppColors.accent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                children: const [
                                  TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500),
                                  ),
                                  TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleRegister,
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                              : Text('Create Account',
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Divider
              FadeInUp(
                delay: const Duration(milliseconds: 450),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or sign up with',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Google Sign-In Button
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: auth.isLoading ? null : _handleGoogleSignIn,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'G',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Google',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Login link
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ",
                        style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: Text('Sign In',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}