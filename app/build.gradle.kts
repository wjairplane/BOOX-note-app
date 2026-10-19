plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "app.inkbridge"
    compileSdk = 35

    defaultConfig {
        applicationId = "app.inkbridge"
        minSdk = 29
        targetSdk = 35
        versionCode = 6
        versionName = "1.1.3"

        // The Note Air5 C is 64-bit ARM; the Onyx SDK only ships ARM native libraries anyway.
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    packaging {
        // Store dex compressed: the Onyx SDK is large, and this keeps the APK small enough to move around.
        dex {
            useLegacyPackaging = true
        }
        jniLibs {
            // Several Onyx SDK modules each bundle the same C++ runtime; any copy will do.
            pickFirsts += "lib/*/libc++_shared.so"
        }
    }

    buildTypes {
        release {
            // Compose is much faster in a release build, which matters on an e-ink panel. The APK is signed with the debug key so it
            // can be sideloaded straight away (use your own keystore to publish it anywhere).
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    testOptions {
        unitTests {
            // Robolectric needs the merged resources and manifest to run Compose screens on the JVM.
            isIncludeAndroidResources = true
            // One JVM per test class: Compose screen tests share static state (fonts, prefs) and the text-tool screens never go idle after other classes ran.
            all { it.setForkEvery(1) }
        }
    }
    buildFeatures {
        compose = true
        buildConfig = true
    }
}

// The Onyx SDK pulls in the legacy com.android.support libraries (via easypermissions); AndroidX replaces them.
configurations.configureEach {
    exclude(group = "com.android.support")
}

dependencies {
    implementation(project(":rmformat"))
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.onyx.pen)
    implementation(libs.hiddenapibypass)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.material3)
    implementation(libs.androidx.material.icons.core)
    debugImplementation(libs.androidx.ui.tooling)

    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(platform(libs.androidx.compose.bom))
    testImplementation(libs.androidx.ui.test.junit4)
    debugImplementation(libs.androidx.ui.test.manifest)
}
