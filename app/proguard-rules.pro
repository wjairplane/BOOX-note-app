# The Onyx pen SDK reaches into the system by reflection and JNI.
-keep class com.onyx.** { *; }
-dontwarn com.onyx.**
-keep class org.lsposed.hiddenapibypass.** { *; }
-dontwarn org.lsposed.hiddenapibypass.**
-dontwarn org.greenrobot.**
-dontwarn com.raizlabs.**
-dontwarn io.reactivex.**
-dontwarn javax.annotation.**
-dontwarn org.apache.**

# kotlinx.serialization (the template files and the library metadata)
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.**
-keepclassmembers class kotlinx.serialization.json.** { *** Companion; }
-keepclasseswithmembers class kotlinx.serialization.json.** { kotlinx.serialization.KSerializer serializer(...); }
-keep,includedescriptorclasses class app.inkbridge.**$$serializer { *; }
-keepclassmembers class app.inkbridge.** { *** Companion; }
-keepclasseswithmembers class app.inkbridge.** { kotlinx.serialization.KSerializer serializer(...); }

# Template and font resources are read by name.
-keepclassmembers class app.inkbridge.R$* { public static <fields>; }

# Libraries the Onyx SDK drags in; their optional back ends are not present.
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
-dontwarn org.joda.convert.**
-dontwarn org.slf4j.**
-dontwarn okhttp3.**
-dontwarn okio.**
