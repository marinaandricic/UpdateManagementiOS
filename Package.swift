// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
 
import PackageDescription

let package = Package(
    name: "UpdateManagementiOS",
    targets: [
        /// Module targets
        .target(
            name: "UpdateManagementiOS",
                dependencies: [],
            path: "Sources/UpdateManagementiOS"),
        .target(
            name: "UpdateManagementiOSObjC",
            dependencies: ["UpdateManagementiOS"],
            path: "Sources/UpdateManagementiOSObjC"),

        /// Tests
        .testTarget(name: "UpdateManagementiOSTests",
                    dependencies: ["UpdateManagementiOS"],
                    path: "Tests/UpdateManagementiOSTests"),
    ],
    swiftLanguageVersions: [.version("5")]
)

/// Main products section
package.products.append(.library(name: "UpdateManagementiOS", type: .dynamic, targets: ["UpdateManagementiOS", "UpdateManagementiOSObjC"]))
