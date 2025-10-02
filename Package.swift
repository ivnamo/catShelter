// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "CatsAdoption",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "CatsCore", targets: ["CatsCore"]),
        .executable(name: "cats-cli", targets: ["cats-cli"])
    ],
    targets: [
        .target(
            name: "CatsCore",
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "cats-cli",
            dependencies: ["CatsCore"]
        )
    ]
)
