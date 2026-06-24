# Bixolon SDK — classes referenced by native JNI (libbxl_common.so)
# R8 removes these as "unused" since they are only accessed via JNI FindClass
-keep class com.bixolon.** { *; }
