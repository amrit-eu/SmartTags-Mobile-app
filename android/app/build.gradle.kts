import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

// CI supplies secrets through environment variables; local releases can use
// android/key.properties (gitignored).
fun signingProperty(environmentVariable: String, property: String): String? =
    System.getenv(environmentVariable)?.takeIf { it.isNotBlank() }
        ?: keystoreProperties.getProperty(property)

android {
    namespace = "com.example.flutter_amrit"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_amrit"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = signingProperty("ANDROID_KEY_ALIAS", "keyAlias")
            keyPassword = signingProperty("ANDROID_KEY_PASSWORD", "keyPassword")
            storePassword = signingProperty("ANDROID_KEYSTORE_PASSWORD", "storePassword")
            storeFile = signingProperty("ANDROID_KEYSTORE_PATH", "storeFile")?.let {
                rootProject.file(it)
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

val validateReleaseSigning by tasks.registering {
    doLast {
        val signing = android.signingConfigs.getByName("release")
        check(
            !signing.keyAlias.isNullOrBlank() &&
                !signing.keyPassword.isNullOrBlank() &&
                !signing.storePassword.isNullOrBlank() &&
                signing.storeFile?.isFile == true
        ) {
            "Release signing requires a keystore, alias, and passwords. " +
                "Configure android/key.properties or the ANDROID_KEYSTORE_PATH, " +
                "ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, and ANDROID_KEY_PASSWORD " +
                "environment variables. See docs/android_releases.md."
        }
    }
}

tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    dependsOn(validateReleaseSigning)
}

flutter {
    source = "../.."
}
