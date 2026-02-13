import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/qr_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/language_provider.dart';
import 'providers/emergency_contacts_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/order_qr_screen.dart';
import 'screens/design_qr_entry_screen.dart';
import 'screens/design_qr_templates_screen.dart';
import 'screens/qr_canvas_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/emergency_contacts_screen.dart';
import 'screens/chat_interface_screen.dart';
import 'screens/tag_details_screen.dart';
import 'screens/updates_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/incoming_call_screen.dart';
import 'screens/live_call_screen.dart';
import 'screens/missed_call_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/payment_history_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/privacy_security_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/about_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ShubhchintakApp());
}

class ShubhchintakApp extends StatelessWidget {
  const ShubhchintakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QRProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyContactsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SHUBHCHINTAK',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/order-qr': (context) => const OrderQRScreen(),
              '/design-qr-entry': (context) => const DesignQREntryScreen(),
              '/design-qr-templates': (context) => const DesignQRTemplatesScreen(),
              '/qr-canvas': (context) => const QRCanvasScreen(),
              '/payment': (context) => const PaymentScreen(),
              '/emergency-contacts': (context) => const EmergencyContactsScreen(),
              '/chat': (context) => const ChatInterfaceScreen(),
              '/tag-details': (context) => const TagDetailsScreen(),
              '/updates': (context) => const UpdatesScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/incoming-call': (context) => const IncomingCallScreen(),
              '/live-call': (context) => const LiveCallScreen(),
              '/missed-call': (context) => const MissedCallScreen(),
              '/edit-profile': (context) => const EditProfileScreen(),
              '/payment-history': (context) => const PaymentHistoryScreen(),
              '/notification-settings': (context) => const NotificationSettingsScreen(),
              '/privacy-security': (context) => const PrivacySecurityScreen(),
              '/help-support': (context) => const HelpSupportScreen(),
              '/about': (context) => const AboutScreen(),
            },
          );
        },
      ),
    );
  }
}