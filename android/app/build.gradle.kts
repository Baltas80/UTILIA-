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
val testAdmobAppId = "ca-app-pub-3940256099942544~3347511713"
val admobAppId = providers.gradleProperty("UTILIA_ADMOB_APP_ID")
    .orElse(testAdmobAppId)
val hasReleaseSigning = listOf(
    signingStoreFile,
    signingStorePassword,
    signingKeyAlias,
    signingKeyPassword,
).all { !it.isNullOrBlank() }

android {
    namespace = "com.utilia.app.utilia"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.utilia.app.utilia"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["ADMOB_APP_ID"] = admobAppId.get()
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
            check(admobAppId.isPresent && admobAppId.get().isNotBlank()) {
                "Production AdMob app ID is not configured. Set UTILIA_ADMOB_APP_ID."
            }
            check(admobAppId.get() != testAdmobAppId) {
                "Google sample AdMob app ID cannot be used for production builds."
            }
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
