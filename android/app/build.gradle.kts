plugins {
    id("org.mozilla.rust-android-gradle.rust-android") version "0.9.6"
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

}

android {
    namespace = "network.beechat.app.kaonic"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "network.beechat.app.kaonic"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

cargo {
    module  = "../../kaonic"
    libname = "kaonic"
    targets = listOf("arm", "arm64", "x86")
    profile = "release"
}

project.afterEvaluate {
    tasks.withType(com.nishtahir.CargoBuildTask::class).forEach { buildTask ->
        tasks.withType(com.android.build.gradle.tasks.MergeSourceSetFolders::class).configureEach {
            this.inputs.dir(
                layout.buildDirectory.dir("rustJniLibs" + File.separatorChar + buildTask.toolchain!!.folder)
            )
            this.dependsOn(buildTask)
        }
    }
}

dependencies {
    implementation("com.github.mik3y:usb-serial-for-android:3.8.0")
}

flutter {
    source = "../.."
}
