// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,] 
        productTypes: [:]
    )
#endif

let package = Package(
    name: "App",
    dependencies: [
        .package(url: "https://github.com/pschuette22/AsyncState", from: "0.2.0"),
        .package(url: "https://github.com/pschuette22/SwiftRequestBuilder", from: "2.1.2"),
    ]
)
