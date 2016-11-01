import HTTPServer
import Graphiti
import GraphQLResponder

let graphql = GraphQLResponder(schema: blogSchema, graphiQL: true, rootValue: noRootValue)

let router = BasicRouter { route in
    route.add(methods: [.get, .post], path: "/graphql", responder: graphql)
}

let contentNegotiation = ContentNegotiationMiddleware(mediaTypes: [.json])
let server = try Server(port: 8080, middleware: [contentNegotiation], responder: router)
try server.start()
