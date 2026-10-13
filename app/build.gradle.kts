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
        versionCode = 1
        versionName = "0.1.0"

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
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    buildFeatures {
        compose = true
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
    implementation(libs.androidx.documentfile)
    implementation(libs.onyx.pen)
    implementation(libs.hiddenapibypass)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.material3)
    debugImplementation(libs.androidx.ui.tooling)
}
