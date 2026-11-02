plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningEnvironment = mapOf(
    "storeFile" to System.getenv("STROT_ANDROID_KEYSTORE_PATH"),
    "storePassword" to System.getenv("STROT_ANDROID_KEYSTORE_PASSWORD"),
    "keyAlias" to System.getenv("STROT_ANDROID_KEY_ALIAS"),
    "keyPassword" to System.getenv("STROT_ANDROID_KEY_PASSWORD"),
)
val releaseBuildRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
val missingReleaseSigningValues = releaseSigningEnvironment
    .filterValues { it.isNullOrBlank() }
    .keys

if (releaseBuildRequested && missingReleaseSigningValues.isNotEmpty()) {
    throw GradleException(
        "Android release signing is not configured. Missing environment-backed values: " +
            missingReleaseSigningValues.joinToString(", "),
    )
}

android {
    namespace = "com.strot.strot_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.strot.strot_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (missingReleaseSigningValues.isEmpty()) {
            create("release") {
                storeFile = file(releaseSigningEnvironment.getValue("storeFile")!!)
                storePassword = releaseSigningEnvironment.getValue("storePassword")
                keyAlias = releaseSigningEnvironment.getValue("keyAlias")
                keyPassword = releaseSigningEnvironment.getValue("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfigs.findByName("release")?.let {
                signingConfig = it
            }
        }
    }
}

flutter {
    source = "../.."
}
