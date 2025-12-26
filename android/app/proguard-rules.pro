# Kaloree ProGuard Rules
# This file contains ProGuard rules to prevent code shrinking from breaking the app

# ==========================================
# Flutter Framework
# ==========================================
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-dontwarn io.flutter.**

# ==========================================
# ML Kit (Google Mobile Vision)
# ==========================================
# Keep ML Kit classes for image labeling and text recognition
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-keep class com.google.mlkit.vision.** { *; }
-keep class com.google.mlkit.common.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.vision.**

# ==========================================
# Drift / SQLite
# ==========================================
# Keep Drift ORM classes
-keep class drift.** { *; }
-keep class com.simolus.** { *; }
-keep class ** extends drift.GeneratedDatabase { *; }
-dontwarn drift.**

# Keep SQLite classes
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }
-dontwarn org.sqlite.**

# ==========================================
# Riverpod State Management
# ==========================================
-keep class riverpod.** { *; }
-keep class com.remi.** { *; }
-dontwarn riverpod.**

# ==========================================
# Camera Plugin
# ==========================================
-keep class io.flutter.plugins.camera.** { *; }
-dontwarn io.flutter.plugins.camera.**

# ==========================================
# Path Provider Plugin
# ==========================================
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# ==========================================
# Secure Storage Plugin
# ==========================================
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# ==========================================
# Dio HTTP Client
# ==========================================
-keep class io.flutter.plugins.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Retrofit does not use
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }

# OkHttp
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ==========================================
# Kotlin
# ==========================================
# Keep Kotlin metadata for reflection
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

# Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# ==========================================
# Generic Rules
# ==========================================
# Preserve line number information for debugging stack traces
-keepattributes SourceFile,LineNumberTable

# Keep generic signature for Kotlin generics
-keepattributes Signature

# Keep annotations
-keepattributes *Annotation*

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep classes that are used with reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# ==========================================
# Gson (if used for JSON serialization)
# ==========================================
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items)
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

# With R8 full mode generic signatures are stripped for classes that are not kept
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

# ==========================================
# Remove Logging in Release
# ==========================================
# Remove Flutter debug logs
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# ==========================================
# Optimization
# ==========================================
# R8 optimization is enabled by default with minifyEnabled = true
# These options are for ProGuard compatibility (R8 ignores them)
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose
