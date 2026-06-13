import 'package:flutter/material.dart';

enum CatppuccinFlavor { latte, frappe, macchiato, mocha }

class CatppuccinPalette {
  final Color base;
  final Color mantle;
  final Color crust;
  final Color surface0;
  final Color surface1;
  final Color surface2;
  final Color text;
  final Color subtext0;
  final Color subtext1;
  final Color accent;   // mauve
  final Color accent2;  // blue
  final Color green;
  final Color red;
  final Color yellow;
  final Color brightness; // Brightness.light or Brightness.dark

  const CatppuccinPalette({
    required this.base,
    required this.mantle,
    required this.crust,
    required this.surface0,
    required this.surface1,
    required this.surface2,
    required this.text,
    required this.subtext0,
    required this.subtext1,
    required this.accent,
    required this.accent2,
    required this.green,
    required this.red,
    required this.yellow,
    required this.brightness,
  });

  Brightness get brightnessValue =>
      brightness == const Color(0x00000000) ? Brightness.light : Brightness.dark;
}

const Map<CatppuccinFlavor, CatppuccinPalette> catppuccinPalettes = {
  CatppuccinFlavor.latte: CatppuccinPalette(
    base: Color(0xFFEFF1F5),
    mantle: Color(0xFFE6E9EF),
    crust: Color(0xFFDCE0E8),
    surface0: Color(0xFFCCD0DA),
    surface1: Color(0xFFBCC0CC),
    surface2: Color(0xFFACB0BE),
    text: Color(0xFF4C4F69),
    subtext0: Color(0xFF6C6F85),
    subtext1: Color(0xFF5C5F77),
    accent: Color(0xFF8839EF),
    accent2: Color(0xFF1E66F5),
    green: Color(0xFF40A02B),
    red: Color(0xFFD20F39),
    yellow: Color(0xFFDF8E1D),
    brightness: Color(0x00000000),
  ),
  CatppuccinFlavor.frappe: CatppuccinPalette(
    base: Color(0xFF303446),
    mantle: Color(0xFF292C3C),
    crust: Color(0xFF232634),
    surface0: Color(0xFF414559),
    surface1: Color(0xFF51576D),
    surface2: Color(0xFF626880),
    text: Color(0xFFC6D0F5),
    subtext0: Color(0xFFA5ADCE),
    subtext1: Color(0xFFB5BFE2),
    accent: Color(0xFFCA9EE6),
    accent2: Color(0xFF8CAAEE),
    green: Color(0xFFA6D189),
    red: Color(0xFFE78284),
    yellow: Color(0xFFE5C890),
    brightness: Color(0xFFFFFFFF),
  ),
  CatppuccinFlavor.macchiato: CatppuccinPalette(
    base: Color(0xFF24273A),
    mantle: Color(0xFF1E2030),
    crust: Color(0xFF181926),
    surface0: Color(0xFF363A4F),
    surface1: Color(0xFF494D64),
    surface2: Color(0xFF5B6078),
    text: Color(0xFFCAD3F5),
    subtext0: Color(0xFFA5ADCB),
    subtext1: Color(0xFFB8C0E0),
    accent: Color(0xFFC6A0F6),
    accent2: Color(0xFF8AADF4),
    green: Color(0xFFA6DA95),
    red: Color(0xFFED8796),
    yellow: Color(0xFFEED49F),
    brightness: Color(0xFFFFFFFF),
  ),
  CatppuccinFlavor.mocha: CatppuccinPalette(
    base: Color(0xFF1E1E2E),
    mantle: Color(0xFF181825),
    crust: Color(0xFF11111B),
    surface0: Color(0xFF313244),
    surface1: Color(0xFF45475A),
    surface2: Color(0xFF585B70),
    text: Color(0xFFCDD6F4),
    subtext0: Color(0xFFA6ADC8),
    subtext1: Color(0xFFBAC2DE),
    accent: Color(0xFFCBA6F7),
    accent2: Color(0xFF89B4FA),
    green: Color(0xFFA6E3A1),
    red: Color(0xFFF38BA8),
    yellow: Color(0xFFF9E2AF),
    brightness: Color(0xFFFFFFFF),
  ),
};

ThemeData buildCatppuccinTheme(CatppuccinFlavor flavor) {
  final p = catppuccinPalettes[flavor]!;
  final brightness = p.brightness == const Color(0x00000000)
      ? Brightness.light
      : Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.base,
    fontFamily: 'JetBrainsMono',
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: p.base,
      secondary: p.accent2,
      onSecondary: p.base,
      error: p.red,
      onError: p.base,
      surface: p.mantle,
      onSurface: p.text,
      surfaceContainerHighest: p.surface0,
      outline: p.surface1,
    ),
    cardColor: p.mantle,
    dividerColor: p.surface0,
    appBarTheme: AppBarTheme(
      backgroundColor: p.base,
      foregroundColor: p.text,
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: p.text),
      bodySmall: TextStyle(color: p.subtext0),
    ),
    iconTheme: IconThemeData(color: p.subtext0),
    cardTheme: CardThemeData(
      color: p.mantle,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: p.surface0, width: 0.5),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: p.mantle,
      selectedItemColor: p.accent,
      unselectedItemColor: p.subtext0,
    ),
    extensions: [
      CatppuccinColors(p),
    ],
  );
}

/// Access extra Catppuccin-only colors not covered by ColorScheme,
/// e.g. Theme.of(context).extension<CatppuccinColors>()!.green
class CatppuccinColors extends ThemeExtension<CatppuccinColors> {
  final CatppuccinPalette palette;
  const CatppuccinColors(this.palette);

  Color get green => palette.green;
  Color get red => palette.red;
  Color get yellow => palette.yellow;
  Color get subtext0 => palette.subtext0;
  Color get surface0 => palette.surface0;
  Color get surface1 => palette.surface1;

  @override
  CatppuccinColors copyWith() => this;

  @override
  CatppuccinColors lerp(ThemeExtension<CatppuccinColors>? other, double t) =>
      this;
}