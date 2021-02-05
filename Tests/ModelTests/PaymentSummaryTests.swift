import XCTest
@testable import PayPal

final class PaymentSummaryTests: XCTestCase {
    func testDecoding()throws {
        let decoder = JSONDecoder()
        
        let valid = """
        {
            "paypal": {
                "currency": "USD",
                "value": "35"
            },
            "other": {
                "currency": "USD",
                "value": "8.43"
            }
        }
        """.data(using: .utf8)!
        
        let summary = try decoder.decode(PaymentSummary.self, from: valid)
        
        XCTAssertEqual(summary.paypal, CurrencyAmount(currency: .usd, value: 35))
        XCTAssertEqual(summary.other, CurrencyAmount(currency: .usd, value: 8.43))
    }
    
    static var allTests: [(String, (PaymentSummaryTests) -> ()throws -> ())] = [
        ("testDecoding", testDecoding)
    ]
}



