import PackageDescription

let package = Package(
    name: "GraphQLExamples",
    dependencies: [
        .Package(url: "https://github.com/Zewo/HTTPServer.git", majorVersion: 0, minor: 14),
        .Package(url: "https://github.com/Zewo/GraphQLResponder.git", majorVersion: 0, minor: 14),
    ]
)
