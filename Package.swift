import PackageDescription

let package = Package(
	name: "Focus",
	targets: [
		Target(
			name: "Focus"),
		],
	dependencies: [
		.Package(url: "https://github.com/typelift/Operadics.git", versions: Version(0,2,2)...Version(0,2,2))
	]
)

let libFocus = Product(name: "Focus", type: .Library(.Dynamic), modules: "Focus")
products.append(libFocus)
