import Vapor

class LogCollection: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.grouped(User.authenticator()).on(.POST, "login", use: logIn(_:))
        routes.grouped(
            Token.authenticator(),
            User.authenticator(),
            User.guardMiddleware()
        ).on(.POST, "logout", use: logOut(_:))
    }

    func logIn(_ req: Request) throws -> EventLoopFuture<AuthorizeMsg> {
        let user = try req.auth.require(User.self)
        let token = try Token.init(user)

        return token.save(on: req.db)
            .map({
                req.auth.login(token)
            })
        .flatMapThrowing({
            try AuthorizeMsg.init(user: user.dataTransferObject(), token: token)
        })
    }

    func logOut(_ req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        try req.auth.require(Token.self)
            .delete(on: req.db)
            .map({
                req.auth.logout(Token.self)
                req.auth.logout(User.self)
            })
            .map({ .ok })
    }
}