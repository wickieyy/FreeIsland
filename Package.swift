// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FreeIsland",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "FreeIsland",
            targets: ["FreeIsland"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "FreeIsland",
            dependencies: [],
            path: "Sources/FreeIsland",
            resources: []
        )
    ]
)
