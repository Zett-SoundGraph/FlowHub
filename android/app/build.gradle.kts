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
    // CafeBeta_FlowHub_<versionName>.<versionCode, zero-padded>-<flavor>.apk
    // — e.g. pubspec.yaml's `version: 0.2.0908+01` (versionName=0.2.0908,
    // versionCode=1) on the prod flavor produces
    // CafeBeta_FlowHub_0.2.0908.01-prod.apk. versionCode IS the same-day
    // build count per this project's versioning convention (see
    // pubspec.yaml's own version comment/history) — bump it manually before
    // each same-day rebuild, same as always; this only changes what the
    // output file is named. `variant.flavorName` ("dev"/"prod") matches
    // CafeBeta-Kiosk's filename convention for fleet-wide consistency. Uses
    // the older applicationVariants API (not androidComponents.onVariants)
    // — the newer Variant API's `output.outputFileName` didn't resolve
    // against this project's AGP version.
    applicationVariants.all {
        val variant = this
        variant.outputs.all {
            val output = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            output.outputFileName =
                "CafeBeta_FlowHub_${variant.versionName}.${variant.versionCode.toString().padStart(2, '0')}-${variant.flavorName}.apk"
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
