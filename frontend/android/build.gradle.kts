import org.gradle.api.tasks.compile.JavaCompile

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
subprojects {
    project.evaluationDependsOn(":app")
}

// Suppress "source value 8 is obsolete" and "deprecated API" warnings from all projects (app + plugins e.g. Razorpay)
gradle.projectsLoaded {
    rootProject.allprojects.forEach { proj ->
        proj.afterEvaluate {
            proj.tasks.withType<JavaCompile>().configureEach {
                doFirst {
                    if (!options.compilerArgs.contains("-Xlint:-options")) {
                        options.compilerArgs.add("-Xlint:-options")
                    }
                    if (!options.compilerArgs.contains("-Xlint:-deprecation")) {
                        options.compilerArgs.add("-Xlint:-deprecation")
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
