import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_translations.dart';
import '../providers/language_provider.dart';

class LanguageSelectionDialog {
  static Future<void> show(BuildContext context, {bool isFirstTime = false}) async {
    final langProvider = context.read<LanguageProvider>();
    String tempSelected = langProvider.currentLanguage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: !isFirstTime,
      enableDrag: !isFirstTime,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final languages = AppTranslations.translations.keys.toList();

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.8,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 24),
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight]),
                    boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: const Icon(Icons.translate_rounded, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(isFirstTime ? 'Choose Your Language' : 'Change Language',
                    style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Select your preferred language for the app',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: languages.length,
                    itemBuilder: (ctx, index) {
                      final langCode = languages[index];
                      final nativeName = AppTranslations.languageNames[langCode] ?? langCode;
                      final englishName = AppTranslations.languageNamesInEnglish[langCode] ?? langCode;
                      final flag = AppTranslations.languageFlags[langCode] ?? '🌐';
                      final isSelected = tempSelected == langCode;

                      return GestureDetector(
                        onTap: () => setSheetState(() => tempSelected = langCode),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accent.withOpacity(0.08) : (isDark ? AppColors.darkBg : AppColors.lightBg),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSelected ? AppColors.accent : Colors.transparent, width: isSelected ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Text(flag, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(nativeName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? AppColors.accent : null)),
                                  if (englishName != nativeName)
                                    Text(englishName, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                ]),
                              ),
                              if (isSelected)
                                Container(width: 28, height: 28, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
                                    child: const Icon(Icons.check_rounded, size: 18, color: Colors.white))
                              else
                                Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle,
                                    border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider, width: 2))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        langProvider.setLanguage(tempSelected);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.language_rounded, size: 22),
                      label: Text('Set Language', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}