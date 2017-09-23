// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name: "Focus",
	products: [
		.library(
			name: "Focus",
			targets: ["Focus"]),
	],
	dependencies: [
		.package(url: "https://github.com/typelift/SwiftCheck.git", .branch("master")),
		.package(url: "https://github.com/typelift/Operadics.git", .branch("master")),
	],
	targets: [
		.target(
			name: "Focus",
			dependencies: ["Operadics"]),
		.testTarget(
			name: "FocusTests",
			dependencies: ["Focus", "Operadics", "SwiftCheck"]),
	]
)

