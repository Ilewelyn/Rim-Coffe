import 'package:flutter/material.dart';

/// Paleta de cafetería: espresso, café tostado, caramelo y crema.
class AppColors {
  AppColors._();

  static const Color espresso = Color(0xFF24160F);
  static const Color cafe = Color(0xFF6B4632);
  static const Color mocha = Color(0xFF8A5A3B);
  static const Color caramel = Color(0xFFC4864F);
  static const Color latte = Color(0xFFE6D3BC);
  static const Color crema = Color(0xFFF3EADF);
  static const Color foam = Color(0xFFFAF6F1);
  static const Color muted = Color(0xFF8C786A);
  static const Color line = Color(0xFFEADFD3);
  static const Color ok = Color(0xFF4C7A55);
  static const Color danger = Color(0xFFB3402F);
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x142B1810), blurRadius: 24, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x0A2B1810), blurRadius: 4, offset: Offset(0, 1)),
  ];
}

/// Tipografías incluidas en la app (assets/fonts):
/// - DM Serif Display para títulos (toque de carta de cafetería).
/// - Poppins para textos, botones y números.
class AppFonts {
  AppFonts._();

  static const String serif = 'DMSerifDisplay';
  static const String sans = 'Poppins';
}

class AppText {
  AppText._();

  /// Títulos grandes de portada (login, bienvenida, turno).
  static const TextStyle display = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.espresso,
    height: 1.1,
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: AppColors.espresso,
    height: 1.15,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.espresso,
    height: 1.2,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.espresso,
    height: 1.2,
  );
  static const TextStyle title = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.espresso,
  );
  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 14,
    color: AppColors.espresso,
    height: 1.4,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 12,
    color: AppColors.muted,
    height: 1.35,
  );
  static const TextStyle label = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: AppColors.cafe,
    letterSpacing: 0.6,
  );
}

ThemeData buildTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.cafe,
    onPrimary: Colors.white,
    secondary: AppColors.caramel,
    onSecondary: Colors.white,
    surface: AppColors.foam,
    onSurface: AppColors.espresso,
    error: AppColors.danger,
    onError: Colors.white,
    primaryContainer: AppColors.latte,
    onPrimaryContainer: AppColors.espresso,
    secondaryContainer: AppColors.crema,
    onSecondaryContainer: AppColors.cafe,
    outline: AppColors.latte,
    outlineVariant: AppColors.line,
  );

  final redondo = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
  const textoBoton = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: AppFonts.sans,
    scaffoldBackgroundColor: AppColors.foam,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.foam,
      foregroundColor: AppColors.espresso,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: AppText.h3,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.foam,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: AppText.h3,
      contentTextStyle: AppText.body,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.foam,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: AppColors.latte,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.cafe,
        foregroundColor: Colors.white,
        shape: redondo,
        textStyle: textoBoton,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cafe,
        side: const BorderSide(color: AppColors.cafe, width: 1.4),
        shape: redondo,
        textStyle: textoBoton,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.cafe,
        textStyle: textoBoton.copyWith(fontSize: 14),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.espresso,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      extendedTextStyle: textoBoton,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.crema,
      side: const BorderSide(color: AppColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: const TextStyle(
        fontFamily: AppFonts.sans,
        fontWeight: FontWeight.w600,
        color: AppColors.cafe,
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.caramel),
    listTileTheme: const ListTileThemeData(iconColor: AppColors.cafe),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.espresso,
      contentTextStyle: const TextStyle(fontFamily: AppFonts.sans, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

/// Decoración de campo de texto: fondo blanco, esquinas redondeadas y
/// borde café al enfocar.
InputDecoration rcInput({
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool enabled = true,
  bool dense = false,
}) {
  OutlineInputBorder borde(Color color, [double ancho = 1.2]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: ancho),
    );
  }

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    isDense: dense,
    filled: true,
    fillColor: enabled ? Colors.white : AppColors.crema,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: borde(AppColors.line),
    enabledBorder: borde(AppColors.line),
    focusedBorder: borde(AppColors.caramel, 1.8),
    disabledBorder: borde(AppColors.line),
    errorBorder: borde(AppColors.danger),
    focusedErrorBorder: borde(AppColors.danger, 1.8),
    errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
  );
}
