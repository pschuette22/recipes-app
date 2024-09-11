import ProjectDescription
import Foundation

guard 
    let swiftVersion = try String(contentsOfFile: ".swift-version")
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .strMap({
            ProjectDescription.Version(stringLiteral: $0)
        })
else {
    fatalError("Failed to read valid swift version from .swift-version file")
}

print("swiftVersion: \(swiftVersion)")
let config = Config(
    compatibleXcodeVersions: ["15.4"],
    swiftVersion: swiftVersion
)

extension String {
    func strMap<T>(_ transform: (String) -> T) -> T? {
        return transform(self)
    }
}