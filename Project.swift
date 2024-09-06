import ProjectDescription

let project = Project(
    name: "Recipes",
    targets: [
        .target(
            name: "Recipes",
            destinations: .iOS,
            product: .app,
            bundleId: "io.palmtreeprogramming.Recipes",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**"],
            dependencies: [
                .external(name: "AsyncState"),
                .external(name: "SwiftRequestBuilder")
            ]
        ),
        .target(
            name: "UnitTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.palmtreeprogramming.Recipes.UnitTests",
            infoPlist: .default,
            sources: ["App/UnitTests/**", "App/Mocks/**.swift"],
            resources: ["App/TestFixtures/**"],
            dependencies: [
                .target(name: "Recipes"),
                .external(name: "SwiftRequestBuilder"),
                .external(name: "SwiftRequestBuilderTestHelpers")
            ]
        ),
    ]
)
