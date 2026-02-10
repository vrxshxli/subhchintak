plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") 
}

android {
    namespace = "com.shubhchintak.app"
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
        applicationId = "com.shubhchintak.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            // IMPORTANT: Update these values!
            storeFile = file("C:/Users/nanav/shubhchintak.jks")  // Forward slashes work on Windows
            // Alternative: file("C:\\Users\\nanav\\shubhchintak.jks") with double backslashes
            storePassword = "123456"     // ← Replace with your actual keystore password
            keyAlias = "shubhchintak"                         // ← Your alias from keytool
            keyPassword = "123456"            // ← Replace (often same as storePassword)
        }
    }

    buildTypes {
        getByName("release") {
            
            signingConfig = signingConfigs.getByName("release")  // Use your real key now
        }
        // Optional: keep debug signing as default
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.0.0"))
    implementation("com.google.firebase:firebase-auth")
}