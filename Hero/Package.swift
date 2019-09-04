// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Hero",
    products: [
        .library(
            name: "HeroModelNet",
            targets: ["HeroModelNet", "HeroModelNet"]),
        .library(
            name: "AlpineSpecific",
            targets: ["AlpineSpecific"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kyouko-taiga/AlpineLang.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "HeroModelNet",
            dependencies: []),
        .target(
            name: "GeneralTools",
            dependencies: ["AlpineLib"]),
        .target(
            name: "AlpineSpecific",
            dependencies: ["HeroModelNet", "GeneralTools"]),
        .testTarget(
            name: "HeroTests",
            dependencies: ["HeroModelNet", "AlpineLib", "AlpineSpecific", "GeneralTools"]),
    ]
)
