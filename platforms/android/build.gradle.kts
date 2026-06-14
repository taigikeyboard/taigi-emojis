// Android library wrapping the shared dist/emoji.json. Consumed by the app as an included
// Gradle module (the app owns plugin versions + the AGP/Kotlin toolchain). assets/emoji.json
// is a symlink to the repo's single generated dist/emoji.json — no copy, no drift.
//
// In the app's settings.gradle(.kts):
//   include(":taigi-emojis")
//   project(":taigi-emojis").projectDir = file("path/to/taigi-emojis/platforms/android")

plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.taigikeyboard.emojis"
    compileSdk = 34

    defaultConfig {
        minSdk = 24
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets["main"].kotlin.srcDir("src/main/kotlin")
}

dependencies {
    // org.json ships with the Android platform — no extra runtime dependency.
}
