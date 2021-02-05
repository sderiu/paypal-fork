import XCTest
import Vapor
@testable import PayPal

final class IdentityTests: XCTestCase {
    
    var app: Application!
    
    override func setUp() {
        super.setUp()
        setPaypalVars()
        
        var services = Services.default()
        try! services.register(PayPalProvider())
        
        app = try! Application.testable(services: services)
    }
    
    func testServiceExists()throws {
        _ = try app.make(Identity.self)
    }
    
    func testInfoEndpoint()throws {
        let identity = try self.app.make(Identity.self)
        let info = try identity.info().wait()
        
        XCTAssertNotNil(info.id)
    }
    
    static var allTests: [(String, (IdentityTests) -> ()throws -> ())] = [
        ("testServiceExists", testServiceExists),
        ("testInfoEndpoint", testInfoEndpoint)
    ]
}
