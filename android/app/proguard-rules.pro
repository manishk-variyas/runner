# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# dartssh3 (native dependencies)
-keep class pointycastle.** { *; }
-keep class pinenacl.** { *; }

# Play Core (missing class warnings)
-dontwarn com.google.android.play.core.**
