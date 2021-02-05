import Vapor

extension Container {
    func paypal<Body>(
        _ method: HTTPMethod,
        _ path: String,
        parameters: QueryParamaters = QueryParamaters(),
        headers: HTTPHeaders = [:],
        auth: Bool = true,
        body: Body? = nil
    )throws -> Request where Body: Content {
        let config = try self.make(Configuration.self)
        let querystring = parameters.encode()
        let path = config.environment.domain + "/" + path + (querystring == "" ? "" : "?" + querystring)
        
        var http = HTTPRequest(method: method, url: path, headers: headers)
        if auth {
            let auth = try self.make(AuthInfo.self)
            guard let type = auth.type, let token = auth.token else {
                throw Abort(.internalServerError, reason: "Attempted to make a PayPal request that requires auth before authenticating.")
            }
            
            http.headers.replaceOrAdd(name: .authorization, value: type + " " + token)
        }
        
        let request = Request(http: http, using: self)
        if let body = body {
            let contentType: MediaType = auth ? .json : .urlEncodedForm
            try request.content.encode(body, as: contentType)
        }
        return request
    }
    
    func paypal<Body, Result>(
        _ method: HTTPMethod,
        _ path: String,
        parameters: QueryParamaters = QueryParamaters(),
        headers: HTTPHeaders = [:],
        body: Body?,
        as response: Result.Type = Result.self
    ) -> Future<Result> where Body: Content, Result: Content {
        #if DEBUG
        var req: Request?
        #endif
        
        return Future.flatMap(on: self) { () -> Future<Void> in
            if try self.make(AuthInfo.self).tokenExpired == true {
                return try self.make(PayPalClient.self).authenticate()
            } else {
                return self.future()
            }
        }.flatMap(to: Response.self) {
            let request = try self.paypal(method, path, parameters: parameters, headers: headers, auth: true, body: body)
            
            #if DEBUG
            if Env.get("PAYPAL_LOG_API_ERROR") == "TRUE" { req = request }
            #endif
            
            return try self.client().send(request)
        }.flatMap(to: Result.self) { response in
            if !(200...299).contains(response.http.status.code) {
                #if DEBUG
                if Env.get("PAYPAL_LOG_API_ERROR") == "TRUE" { print(req!, "\n\n", response) }
                #endif
                
                guard response.http.headers.firstValue(name: .contentType) == "application/json" else {
                    let body = response.http.body.data ?? Data()
                    let error = String(data: body, encoding: .utf8)
                    throw Abort(response.http.status, reason: error)
                }
                
                return try response.content.decode(PayPalAPIError.self).catchFlatMap { _ in
                    return try response.content.decode(PayPalAPIIdentityError.self).map { error in throw error }
                }.map { error in
                    throw error
                }
            }
            
            if Result.self is HTTPStatus.Type {
                return self.future(response.http.status as! Result)
            }
            return try response.content.decode(Result.self)
        }
    }
    
    func paypal<Result>(
        _ method: HTTPMethod,
        _ path: String,
        parameters: QueryParamaters = QueryParamaters(),
        headers: HTTPHeaders = [:],
        as response: Result.Type = Result.self
    ) -> Future<Result> where Result: Content {
        return self.paypal(method, path, parameters: parameters, headers: headers, body: nil as [String: String]?, as: Result.self)
    }
}
