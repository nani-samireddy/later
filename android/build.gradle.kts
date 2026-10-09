import com.android.build.api.variant.LibraryAndroidComponentsExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// receive_sharing_intent declares API 37 without the published minor version.
// Correct its DSL in this project rather than modifying the shared pub cache.
subprojects {
    if (name == "receive_sharing_intent") {
        plugins.withId("com.android.library") {
            extensions.configure<LibraryAndroidComponentsExtension> {
                finalizeDsl { android ->
                    android.compileSdk {
                        version = release(37) { minorApiLevel = 0 }
                    }
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
