import Vapor

typealias Env = Vapor.Environment

/// Configures services required for PayPal API interaction
///
/// - `Configuration`
/// - `AuthInfo`
/// - `PayPalClient`
public final class PayPalProvider: Vapor.Provider {
    
    let version: Version
    let clientID: String
    let clientSecret: String
    
    /// Creates a new `PayPal.Provider` instance to register with an
    /// application's `Services`.
    ///
    ///      try services.register(PayPal.Provider())
    ///
    /// - Parameters:
    ///   - version: The version of the PayPal API to use when making requests.
    ///   - id: The client ID for the PayPal app the connect to.
    ///   - secret: The client secret for the PayPal app to connect to.
    public init(version: Version = .v1, id: String, secret: String) {
        self.version = version
        self.clientID = id
        self.clientSecret = secret
    }
    
    /// Registers all services to the app's services.
    public func register(_ services: inout Services) throws {
        services.register(Configuration(id: self.clientID, secret: self.clientSecret, version: self.version))
        
        services.register(AuthInfo())
        services.register(PayPalClient.self)
        
        // Register API Controllers
        services.register(Activities.self)
        services.register(BillingAgreements.self)
        services.register(BillingPlans.self)
        services.register(CustomerDisputes.self)
        services.register(Identity.self)
        services.register(Invoices.self)
        services.register(Templates.self)
        services.register(ManagedAccounts.self)
        services.register(Orders.self)
        services.register(Payments.self)
        
        var content = ContentConfig.default()
        content.use(httpDecoder: MultipartRelatedDecoder(), for: .related)
        content.use(httpEncoder: MultipartRelatedEncoder(), for: .related)
        services.register(content)
    }
    
    /// Gets the current app environment and registers the proper PayPal environment to the configuration.
    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        let config = try container.make(Configuration.self)
        config.environment = container.environment.isRelease ? .production : .sandbox
        
        return container.future()
    }
}

/// Global configuration data required to use the PayPal API.
public final class Configuration: Service {
    
    /// Your PayPal client ID.
    public let id: String
    
    /// Your PayPal client secret value.
    public let secret: String
    
    /// The version of the PayPal API being used.
    public let version: Version
    
    /// The PayPal environment to send requests to.
    /// This value is based on the app's current environment.
    ///
    /// If the app was boot in a release environment, it will
    /// be `.production`, otherwise it will be `.sandbox`.
    public internal(set) var environment: PayPal.Environment!
    
    init(id: String, secret: String, version: Version) {
        self.id = id
        self.secret = secret
        self.environment = nil
        self.version = version
    }
}
