# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
-keepattributes SourceFile,LineNumberTable

# Keep annotation information
-keepattributes *Annotation*

# Keep generic signatures for proper type inference
-keepattributes Signature

# Keep inner classes
-keepattributes InnerClasses,EnclosingMethod

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Kaonic plugin specific rules
-keep class network.beechat.app.kaonic.** { *; }

# ObjectBox rules
-keep class io.objectbox.** { *; }
-keep @io.objectbox.annotation.Entity class * { *; }

# Jackson serialization rules
-keep class com.fasterxml.jackson.** { *; }
-dontwarn com.fasterxml.jackson.**

# USB Serial rules
-keep class com.hoho.android.usbserial.** { *; }

# Google Play Core rules - ignore missing classes since they're optional
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Flutter deferred components - keep what's available, ignore what's missing
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication

# Keep all classes that might be referenced by reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Prevent obfuscation of Flutter embedding classes
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.common.** { *; }
