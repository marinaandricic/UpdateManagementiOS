// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
 
import PackageDescription

let package = Package(
    name: "UpdateManagementFramework",
    targets: [
        /// Module targets
        .target(name: "UpdateManagementFramework",     dependencies: [],             path: "Sources/UpdateManagementFramework"),
        .target(name: "UpdateManagementFrameworkObjC", dependencies: ["UpdateManagementFramework"],   path: "Sources/UpdateManagementFrameworkObjC"),

        /// Tests
        .testTarget(name: "UpdateManagementFrameworkTests",     dependencies: ["UpdateManagementFramework"],     path: "Tests/UpdateManagementFrameworkTests"),
    ],
    swiftLanguageVersions: [.version("5")]
)

/// Main products section
package.products.append(.library(name: "UpdateManagementFramework", type: .dynamic, targets: ["UpdateManagementFramework", "UpdateManagementFrameworkObjC"]))
