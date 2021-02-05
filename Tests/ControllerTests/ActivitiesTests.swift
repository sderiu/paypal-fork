import XCTest
import Vapor
@testable import PayPal

final class ActivitiesTests: XCTestCase {
    
    var app: Application!
    
    override func setUp() {
        super.setUp()
        setPaypalVars()
        
        var services = Services.default()
        try! services.register(PayPalProvider())
        
        app = try! Application.testable(services: services)
    }
    
    func testServiceExists()throws {
        _ = try app.make(Activities.self)
    }
    
    func testActivitiesEndpoint()throws {
        let activities = try app.make(Activities.self)
        
        let plain = try activities.activities().wait()
        let queried = try activities.activities(parameters: QueryParamaters(page: 0, pageSize: 5)).wait()
        
        XCTAssertGreaterThan(plain.items?.count ?? 0, 0)
        XCTAssertLessThanOrEqual(queried.items?.count ?? 0, 5)
    }
    
    static var allTests: [(String, (ActivitiesTests) -> ()throws -> ())] = [
        ("testServiceExists", testServiceExists),
        ("testActivitiesEndpoint", testActivitiesEndpoint)
    ]
}

