//*plugins {
//    id("com.android.application")
//    id("org.jetbrains.kotlin.android")
//    id("dev.flutter.flutter-gradle-plugin") // mandatory
//    id("com.google.gms.google-services")
//}
//
//android {
//    namespace = "com.example.project"
//    compileSdk = 34
//
//    defaultConfig {
//        applicationId = "com.example.project"
//        minSdk = flutter.minSdkVersion
//        targetSdk = 34
//        versionCode = 1
//        versionName = "1.0"
//    }
//}
//
//flutter {
//    source = "../.."
//}
//
//dependencies {
//    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
//    implementation("com.google.firebase:firebase-auth")
//    implementation("com.google.firebase:firebase-firestore")
//}*/
//
//plugins {
//    id("com.android.application")
//    id("kotlin-android")
//    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
//    id("dev.flutter.flutter-gradle-plugin")
//    // Add the Google services Gradle plugin
//    id("com.google.gms.google-services")
//}
//
//android {
//    namespace = "com.example.project"
//    compileSdk = flutter.compileSdkVersion
//    ndkVersion = flutter.ndkVersion
//
//    compileOptions {
//        sourceCompatibility = JavaVersion.toVersion(17)
//        targetCompatibility = JavaVersion.toVersion(17)
//    }
//// Line 51 par ye likhen:
////    kotlinOptions {
////        (this as org.jetbrains.kotlin.gradle.dsl.KotlinJvmOptions).jvmTarget = "17"
////    }
////    kotlinOptions {
////        jvmTarget = "17"
////    }
////    kotlinOptions {
////        jvmTarget = "17"
////    }
//    kotlin {
//        compilerOptions {
//            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
//        }
//    }
//
//    defaultConfig {
//        applicationId = "com.example.project"
//        minSdk = flutter.minSdkVersion
//        targetSdk = flutter.targetSdkVersion
//        versionCode = flutter.versionCode
//        versionName = flutter.versionName
//    }
//
//    buildTypes {
//        release {
//            signingConfig = signingConfigs.getByName("debug")
//        }
//    }
//}
//
//flutter {
//    source = "../.."
//}
//
//// -------------------------
//// Firebase Dependencies
//// -------------------------
//dependencies {
//    // Firebase BoM ensures compatible versions
//    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
//
//    // Firebase Analytics
//    implementation("com.google.firebase:firebase-analytics")
//
//    // Add other Firebase products if needed:
//    implementation("com.google.firebase:firebase-auth")
//    implementation("com.google.firebase:firebase-firestore")
//    implementation("com.google.firebase:firebase-messaging")
//}


plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.project"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        applicationId = "com.example.project"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// ✅ IMPORTANT FIX (firebase-iid remove)
configurations.all {
    exclude(group = "com.google.firebase", module = "firebase-iid")
}

// -------------------------
// Firebase Dependencies
// -------------------------
dependencies {
    // Firebase BoM (latest stable)
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))

    // Firebase products
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-messaging")
}