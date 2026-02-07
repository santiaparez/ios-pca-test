// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PCAStudy",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "PCAStudyCore", targets: ["PCAStudyCore"])
    ],
    targets: [
        .target(
            name: "PCAStudyCore",
            path: "Sources/PCAStudyCore"
        ),
        .testTarget(
            name: "PCAStudyCoreTests",
            dependencies: ["PCAStudyCore"],
            path: "Tests/PCAStudyCoreTests"
        )
    ]
)
