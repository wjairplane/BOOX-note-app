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
    }
}

rootProject.name = "InkBridge"

// Pure-Kotlin .rm v6 parser + platform-neutral renderer (runs on the JVM, unit-tested without a device).
include(":rmformat")
// Android app for the BOOX Note Air5 C.
include(":app")
