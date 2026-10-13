pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        // Onyx's pen SDK is only published here, and only over plain HTTP. Restrict this repository
        // to the SDK's own group plus the three third-party groups it depends on, so nothing else
        // is ever resolved through it.
        maven {
            url = uri("http://repo.boox.com/repository/maven-public/")
            isAllowInsecureProtocol = true
            content {
                includeGroup("com.onyx.android.sdk")
                includeGroup("pub.devrel")
                includeGroup("com.tencent")
                includeGroup("com.jakewharton.hugo.fix")
            }
        }
        // Transitive dependencies of the Onyx SDK that are hosted on JitPack.
        maven {
            url = uri("https://jitpack.io")
            content { includeGroupByRegex("com\\.github\\..*") }
        }
    }
}

rootProject.name = "InkBridge"

// Pure-Kotlin .rm v6 parser + platform-neutral renderer (runs on the JVM, unit-tested without a device).
include(":rmformat")
// Android app for the BOOX Note Air5 C. Pass -PrmOnly to skip it (fast JVM-only parser/renderer builds).
if (!providers.gradleProperty("rmOnly").isPresent) {
    include(":app")
}
