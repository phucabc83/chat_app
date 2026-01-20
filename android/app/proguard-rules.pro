# Zego Express Engine - Prevent obfuscation and null pointer errors
-keep class **.zego.** { *; }
-keep class im.zego.** { *; }
-keep interface im.zego.** { *; }
-keep enum im.zego.** { *; }

# Zego native libraries
-keep class im.zego.zegoexpress.ZegoExpressEngine { *; }
-keep class im.zego.zegoexpress.callback.** { *; }
-keep class im.zego.zegoexpress.constants.** { *; }
-keep class im.zego.zegoexpress.entity.** { *; }

# Zego UIKit
-keep class com.zegocloud.** { *; }

# Google services
-keep class com.google.** { *; }
-dontwarn com.google.**

# Prevent stripping of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}
