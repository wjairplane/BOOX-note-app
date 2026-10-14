import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    alias(libs.plugins.kotlin.jvm)
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    // Only the JSON tree parser is used (for .content/.metadata); no serialization plugin needed.
    implementation(libs.kotlinx.serialization.json)
    testImplementation(libs.junit)
}

tasks.test {
    // Rendered PNGs from RenderSnapshotTest land here for eyeballing.
    systemProperty("rm.renderOut", layout.buildDirectory.dir("render-snapshots").get().asFile.absolutePath)
}
