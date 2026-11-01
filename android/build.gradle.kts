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

// reactive_ble_mobile (battito via Bluetooth) compila ancora con l'SDK 33, troppo
// vecchio per le sue librerie androidx: si porta allo stesso dell'app.
subprojects {
    if (name == "reactive_ble_mobile") {
        val alza = {
            extensions.getByName("android").withGroovyBuilder { "compileSdkVersion"(36) }
        }
        if (state.executed) alza() else afterEvaluate { alza() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
