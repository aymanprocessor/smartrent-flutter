# ProGuard/R8 rules for the app
# Suppress missing class warning for SLF4J binding referenced by some libs
-dontwarn org.slf4j.impl.StaticLoggerBinder
