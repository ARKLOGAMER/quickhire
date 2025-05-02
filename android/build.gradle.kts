// Apply the required plugins at the top
plugins {
    id("com.android.application") // For app-level build.gradle.kts
    kotlin("android") // Kotlin support
    id("com.google.gms.google-services") // Ensure it's applied correctly
}

// Ensure repositories are set up correctly
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Android configuration
android {
    namespace = "com.example.quickhire1" // Your package name
    compileSdk = 33

    defaultConfig {
        applicationId = "com.example.quickhire1" // Must match namespace
        minSdk = 23
        targetSdk = 33
    }

    ndkVersion = "27.0.12077973" // Ensure correct NDK version
}

