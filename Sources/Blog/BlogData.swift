// Translated from https://github.com/kadirahq/graphql-blog-schema

import struct Foundation.Date
import struct Foundation.UUID

enum Category : String {
    case server = "server-side-swift"
    case optimization = "optimization"
    case release = "release"
}

struct Author {
    let id: String
    let name: String
    let twitterHandle: String?
}

var AuthorsMap: [String: Author] = [
    "seabaylea": Author(
        id: "seabaylea",
        name: "Chris Bailey",
        twitterHandle: "@Chris__Bailey"
    ),
    "eeckstein": Author(
        id: "eeckstein",
        name: "Erik Eckstein",
        twitterHandle: "@eeckstein"
    ),
    "tkremenek": Author(
        id: "tkremenek",
        name: "Ted Kremenek",
        twitterHandle: "@tkremenek"
    )
]

struct Comment {
    let id: String
    let content: String
    let author: String
}

let CommentList: [Comment]  = [
    Comment(
        id: UUID().uuidString,
        content: "This is a very good blog post",
        author: "tkremenek"
    ),
    Comment(
        id: UUID().uuidString,
        content: "Keep up the good work",
        author: "seabaylea"
    )
]

let ReplyList: [Comment] = [
    Comment(
        id: UUID().uuidString,
        content: "Thank You!",
        author: "eeckstein"
    ),
    Comment(
        id: UUID().uuidString,
        content: "If you need more information, just contact me.",
        author: "eeckstein"
    ),
]

struct Post {
    let id: String
    let author: String
    let category: Category?
    let content: String
    let date: Date
    let summary: String
    let title: String
}

var PostsList = [
    Post(
        id: "0176413761b289e6d64c2c14a758c1c7",
        author: "seabaylea",
        category: .server,
        content: "Since Swift became available on Linux there has been a huge amount of interest in using Swift on the server, resulting in the emergence of a number of Web Frameworks, including Kitura, Vapor, Perfect, and Zewo, along with many others. As an important part of the Swift ecosystem, and one that we are keen to foster, we are today announcing the formation of the Server APIs work group.\n\nThe work group provides the framework for participants in the the community with an interest in building server applications and frameworks to come together to work on providing new Swift APIs. These APIs will provide low level “server” functions as the basic building blocks for developing server-side capabilities, removing the reliance on interfacing with generally platform specific C libraries for these functions. This will enable more developers to create frameworks and server applications using pure-Swift code, without the need to also have systems programming skills and knowledge of multiple platforms.\n\nThe work group will initially be looking at APIs for networking, security, and HTTP/WebSocket parsing, with the goal of making it possible for anyone to build a simple, secure, HTTP server, or to start to build other server frameworks like pub/sub message brokers.\n\nFor more information, take a look at the Server APIs project page.",
        date: Date(),
        summary: "Since Swift became available on Linux there has been a huge amount of interest in using Swift on the server...",
        title: "Server APIs Work Group"
    ),
    Post(
        id: "03390abb5570ce03ae524397d215713b",
        author: "eeckstein",
        category: .optimization,
        content: "Whole-module optimization is an optimization mode of the Swift compiler. The performance win of whole-module optimization heavily depends on the project, but it can be up to two or even five times.\n\nWhole-module optimization can be enabled with the -whole-module-optimization (or -wmo) compiler flag, and in Xcode 8 it is turned on by default for new projects. Also the Swift Package Manager compiles with whole-module optimizations in release builds.\n\nSo what is it about? Let’s first look at how the compiler works without whole-module optimizations.",
        date: Date(),
        summary: "Whole-module optimization is an optimization mode of the Swift compiler. The performance win of whole-module optimization heavily depends on the project, but it can be up to two or even five times...",
        title: "Whole-Module Optimization in Swift 3"
    ),
    Post(
        id: "0be4bea0330ccb5ecf781a9f69a64bc8",
        author: "tkremenek",
        category: .release,
        content: "Swift 3.0, the first major release of Swift since it was open-sourced, is now officially released! Swift 3 is a huge release containing major improvements and refinements to the core language and Standard Library, major additions to the Linux port of Swift, and the first official release of the Swift Package Manager.",
        date: Date(),
        summary: "Swift 3.0, the first major release of Swift since it was open-sourced, is now officially released!..",
        title: "Swift 3.0 Released!"
    ),
]
