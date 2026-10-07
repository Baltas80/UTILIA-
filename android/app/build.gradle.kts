plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingStoreFile = System.getenv("UTILIA_KEYSTORE_FILE")
val signingStorePassword = System.getenv("UTILIA_KEYSTORE_PASSWORD")
val signingKeyAlias = System.getenv("UTILIA_KEY_ALIAS")
val signingKeyPassword = System.getenv("UTILIA_KEY_PASSWORD")
val admobAppId = providers.gradleProperty("UTILIA_ADMOB_APP_ID").orNull
    ?: error("UTILIA_ADMOB_APP_ID must be configured for every Android build.")
val hasReleaseSigning = listOf(
    signingStoreFile,
    signingStorePassword,
    signingKeyAlias,
    signingKeyPassword,
).all { !it.isNullOrBlank() }

check(admobAppId != "ca-app-pub-3940256099942544~3347511713") {
    "Google test AdMob App ID is not permitted in UTILIA builds."
}

android {
    namespace = "com.utilia.app.utilia"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.utilia.app.utilia"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["ADMOB_APP_ID"] = admobAppId
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(signingStoreFile!!)
                storePassword = signingStorePassword
                keyAlias = signingKeyAlias
                keyPassword = signingKeyPassword
            }
        }
    }

    buildTypes {
        release {
            check(hasReleaseSigning) {
                "Production release signing is not configured. Set UTILIA_KEYSTORE_FILE, " +
                    "UTILIA_KEYSTORE_PASSWORD, UTILIA_KEY_ALIAS and UTILIA_KEY_PASSWORD."
            }
            signingConfig = signingConfigs.getByName("release")
        }
    }

    dependencies {
        // Pin the Android Play Billing client used by the Flutter IAP implementation.
        implementation("com.android.billingclient:billing-ktx:9.1.0")
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}
