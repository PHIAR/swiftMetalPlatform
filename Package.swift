// swift-tools-version:5.2

import PackageDescription

var products: [Product] = []
var targets: [Target] = []

// MARK - Metal

let metalProtocolsTarget = Target.target(name: "MetalProtocols",
                                         dependencies: [])
let metalTarget = Target.target(name: "Metal",
                                dependencies: [
    "MetalProtocols",
    "swiftVulkan",
],
                                path: "Sources/MetalVulkanBackend")
let metalTestTarget = Target.testTarget(name: "swiftMetalPlatformTests",
                                        dependencies: [
    "Metal",
])

targets.append(metalProtocolsTarget)
targets.append(metalTarget)
targets.append(metalTestTarget)

// MARK - Package configuration

products.append(.library(name: "Metal",
                         type: .dynamic,
                         targets: [
    "Metal",
]))

let package = Package(name: "swiftMetalPlatform",
                      products: products,
                      dependencies: [
    .package(url: "https://github.com/PHIAR/swiftVulkan.git",
             .branch("master")),
],
                      targets: targets)

