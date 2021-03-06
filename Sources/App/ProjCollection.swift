import Vapor
import Fluent

class ProjCollection: ApiCollection {
    
    typealias T = Project
    
    func boot(routes: RoutesBuilder) throws {
        let routes = routes.grouped(.constant(T.schema))
        
        routes.on(.GET, use: readAll)
        routes.on(.GET, .parameter(restfulIDKey), use: read)
        
        let trusted = routes.grouped([
            User.authenticator(),
            Token.authenticator(),
            User.guardMiddleware()
        ])
        
        trusted.on(.POST, use: create)
        trusted.on(.PUT, .parameter(restfulIDKey), use: update)
        trusted.on(.DELETE, .parameter(restfulIDKey), use: delete)
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<T.DTO> {
        let user = try req.auth.require(User.self)
        
        var serializedObject = try req.content.decode(T.DTO.self)
        serializedObject.userId = try user.requireID()
        
        let model = try T.init(from: serializedObject)
        model.id = nil
        
        return user.$projects.create(model, on: req.db)
            .flatMapThrowing({
                try model.dataTransferObject()
            })
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<T.Coding> {
        
        let user = try req.auth.require(User.self)
        let id = try req.parameters.require(restfulIDKey, as: T.IDValue.self)
        
        var model = try req.content.decode(T.DTO.self)
        model.userId = try user.requireID()
        
        return user.$projects.query(on: req.db)
            .filter(\.$id == id)
            .first()
            .unwrap(orError: Abort(.notFound))
            .flatMap({ exist -> EventLoopFuture<T> in
                do {
                    return try exist.update(with: model)
                        .update(on: req.db)
                        .map { exist }
                } catch {
                    return req.eventLoop.makeFailedFuture(error)
                }
            })
            .flatMapThrowing({
                try $0.dataTransferObject()
            })
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        let user = try req.auth.require(User.self)
        let id = try req.parameters.require(restfulIDKey, as: T.IDValue.self)
        return user.$projects.query(on: req.db)
            .filter(\.$id == id)
            .first()
            .unwrap(orError: Abort(.notFound))
            .flatMap({
                $0.delete(on: req.db)
            })
            .map({ .ok })
    }
}
