plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.soundgraph.flow.hub"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("src/main/jniLibs")
        }
    }

    defaultConfig {
        applicationId = "com.soundgraph.flow.hub"
        // Org-wide standard value — 23 covers the oldest device in the
        // fleet (Android 6 FrameTV); the 160T unit runs Android 16, so the
        // whole fleet's range is 23-36.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appName"] = "Cafe Beta FlowHub"
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appName"] = "Cafe Beta FlowHub Dev"
        }
        create("prod") {
            dimension = "env"
            manifestPlaceholders["appName"] = "Cafe Beta FlowHub"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    // Renames the output APK from Flutter's default (app-dev-release.apk /
    // app-prod-release.apk) to
    // CafeBeta_FlowHub_<flavor>_<versionName>.<versionCode>.apk
    // — e.g. pubspec.yaml's `version: 0.10.261027+26102701` on the prod
    // flavor produces CafeBeta_FlowHub_prod_0.10.261027.26102701.apk.
    // Fleet-wide versioning convention: versionName is A.BC.YYMMDD (A=major/
    // store-open status, BC=shared Cafe Beta protocol+feature generation,
    // YYMMDD=build date) and versionCode is YYMMDDNN (same date, NN=that
    // day's build count starting at 01) — bump both by hand before each
    // build, and never let versionCode go back down across days either
    // (Android rejects an update whose versionCode isn't strictly greater
    // than what's already installed). `variant.flavorName` ("dev"/"prod")
    // matches CafeBeta-Kiosk's filename convention for fleet-wide
    // consistency. Deliberately uses `flutter.versionName` (the raw
    // pubspec.yaml value) rather than `variant.versionName` here — the dev
    // flavor's own `versionNameSuffix = "-dev"` (see productFlavors above)
    // would otherwise make "dev" appear twice in the filename. Uses the
    // older applicationVariants API (not androidComponents.onVariants) —
    // the newer Variant API's `output.outputFileName` didn't resolve
    // against this project's AGP version.
    applicationVariants.all {
        val variant = this
        variant.outputs.all {
            val output = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            output.outputFileName =
                "CafeBeta_FlowHub_${variant.flavorName}_${flutter.versionName}.${variant.versionCode}.apk"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar", "*.aar"))))
    implementation("org.jetbrains.kotlin:kotlin-stdlib")
}
