// Translated from https://github.com/kadirahq/graphql-blog-schema

import Graphiti
import struct Foundation.Date

extension Category : InputType, OutputType {
    init(map: Map) throws {
        guard
            let name = map.string,
            let category = Category(rawValue: name)
            else {
                throw MapError.incompatibleType
        }

        self = category
    }

    func asMap() throws -> Map {
        return rawValue.map
    }
}

extension Author  : OutputType {}
extension Comment : OutputType {}
extension Post    : OutputType {}

protocol HasAuthor {
    var author: String { get }
}

extension Comment : HasAuthor {}
extension Post    : HasAuthor {}

enum BlogError : Error {
    case postAlreadyExists(id: String)
    case noSuchAuthor(author: String)
    case authorAlreadyExists(id: String)
}

extension BlogError : CustomStringConvertible {
    var description: String {
        switch self {
        case .postAlreadyExists(let id):
            return "Post already exists: \(id)"
        case .noSuchAuthor(let author):
            return "No such author: \(author)"
        case .authorAlreadyExists(let id):
            return "Author already exists: \(id)"
        }
    }
}

let blogSchema = try! Schema<Void> { schema in
    try EnumType<Category>(name: "Category") { category in
        category.description = "A Category of the blog"

        try category.value(name: "SERVER", value: .server)
        try category.value(name: "OPTIMIZATION", value: .optimization)
        try category.value(name: "RELEASE", value: .release)
    }

    try ObjectType<Author>(name: "Author") { author in
        author.description = "Represent the type of an author of a blog post or a comment"

        try author.field(name: "id", type: String.self)
        try author.field(name: "name", type: String.self)
        try author.field(name: "twitterHandle", type: (String?).self)
    }

    try InterfaceType<HasAuthor>(name: "HasAuthor") { author in
        author.description = "This type has an author"

        try author.field(name: "author", type: Author.self)

        author.resolveType { value, _, _ in
            switch value {
            case is Post:
                return Post.self
            default:
                return Comment.self
            }
        }
    }

    try ObjectType<Comment>(name: "Comment", interfaces: HasAuthor.self) { comment in
        comment.description = "Represent the type of a comment"

        try comment.field(name: "id", type: String.self)
        try comment.field(name: "content", type: String.self)

        try comment.field(name: "author", type: Author.self) { comment, _, _, _ in
            guard let author = AuthorsMap[comment.author] else {
                throw BlogError.noSuchAuthor(author: comment.author)
            }

            return author
        }

        try comment.field(name: "timestamp", type: (Double?).self)

        try comment.field(
            name: "replies",
            type: [TypeReference<Comment>].self,
            description: "Replies for the comment"
        ) { _ in
            ReplyList
        }
    }

    try ObjectType<Post>(name: "Post", interfaces: HasAuthor.self) { post in
        post.description = "Represent the type of a blog post"

        try post.field(name: "id", type: String.self)
        try post.field(name: "title", type: String.self)
        try post.field(name: "category", type: (Category?).self)
        try post.field(name: "summary", type: String.self)
        try post.field(name: "content", type: String.self)

        try post.field(name: "timestamp", type: Double.self) { post, _, _, _ in
            post.date.timeIntervalSince1970
        }

        struct LimitArgument : Argument {
            let value: Int
            static let defaultValue: DefaultValue? = nil
            static let description: String? = "Limit the comments returing"
        }

        struct CommentsArguments : Arguments {
            let limit: LimitArgument
        }

        try post.field(name: "comments", type: [Comment].self) { (_, arguments: CommentsArguments, _, _) in
            if arguments.limit.value >= 0 {
                return Array(CommentList.prefix(arguments.limit.value))
            }

            return CommentList
        }

        try post.field(name: "author", type: Author.self) { post, _, _, _ in
            guard let author = AuthorsMap[post.author] else {
                throw BlogError.noSuchAuthor(author: post.author)
            }

            return author
        }
    }

    schema.query = try ObjectType(name: "BlogSchema") { query in
        query.description = "Root of the Blog Schema"

        struct PostsArguments : Arguments {
            let category: Category?
        }

        try query.field(
            name: "posts",
            type: [Post].self,
            description: "List of posts in the blog"
        ) { (_, arguments: PostsArguments, _, _) in
            if let category = arguments.category {
                return PostsList.filter({ $0.category == category })
            }

            return PostsList
        }

        try query.field(
            name: "latestPost",
            type: (Post?).self,
            description: "Latest post in the blog"
        ) { _ in
            PostsList.sorted(by: { $0.date < $1.date }).first
        }

        struct PostCountArgument : Argument {
            let value: Int
            static let defaultValue: DefaultValue? = nil
            static let description: String? = "Number of recent items"
        }

        struct RecentPostsArguments : Arguments {
            let count: PostCountArgument
        }

        try query.field(
            name: "recentPosts",
            type: [Post].self,
            description: "Recent posts in the blog"
        ) { (_, arguments: RecentPostsArguments, _, _) in
            Array(PostsList.sorted(by: { $0.date < $1.date }).prefix(arguments.count.value))
        }

        struct PostArguments : Arguments {
            let id: String
        }

        try query.field(
            name: "post",
            type: (Post?).self,
            description: "Post by id"
        ) { (_, arguments: PostArguments, _, _) in
            PostsList.filter({ $0.id == arguments.id }).first
        }

        try query.field(
            name: "authors",
            type: [Author].self,
            description: "Available authors in the blog"
        ) { _ in
            Array(AuthorsMap.values)
        }

        struct AuthorArguments : Arguments {
            let id: String
        }

        try query.field(
            name: "author",
            type: (Author?).self,
            description: "Author by id"
        ) { (_, arguments: AuthorArguments, _, _) in
            AuthorsMap[arguments.id]
        }
    }

    schema.mutation = try ObjectType(name: "BlogMutations") { mutation in
        struct AuthorArgument : Argument {
            let value: String
            static let defaultValue: DefaultValue? = nil
            static let description: String? = "Id of the author"
        }

        struct CreatePostArguments : Arguments {
            let id: String
            let title: String
            let content: String
            let summary: String?
            let category: Category?
            let author: AuthorArgument
        }

        try mutation.field(
            name: "createPost",
            type: (Post).self,
            description: "Create a new blog post"
        ) { (_, arguments: CreatePostArguments, _, _) in
            let post = Post(
                id: arguments.id,
                author: arguments.author.value,
                category: arguments.category,
                content: arguments.content,
                date: Date(),
                summary: arguments.summary ?? String(arguments.content.characters.prefix(100)),
                title: arguments.title
            )

            let alreadyExists = PostsList.contains(where: { $0.id == post.id })

            if alreadyExists {
                throw BlogError.postAlreadyExists(id: post.id)
            }

            if AuthorsMap[post.author] == nil {
                throw BlogError.noSuchAuthor(author: post.author)

            }

            PostsList.append(post)

            return post
        }

        struct CreateAuthorArguments : Arguments {
            let id: String
            let name: String
            let twitterHandle: String?
        }

        try mutation.field(
            name: "createAuthor",
            type: (Author).self,
            description: "Create a new author"
        ) { (_, arguments: CreateAuthorArguments, _, _) in
            let author = Author(
                id: arguments.id,
                name: arguments.name,
                twitterHandle: arguments.twitterHandle
            )

            if AuthorsMap[author.id] != nil {
                throw BlogError.authorAlreadyExists(id: author.id)
            }

            AuthorsMap[author.id] = author
            
            return author
        }
    }
}
