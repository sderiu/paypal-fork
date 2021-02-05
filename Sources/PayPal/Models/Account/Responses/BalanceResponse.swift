import Vapor

/// The current balance of an account.
public struct BalanceResponse: Content, Equatable {
    
    /// An immutable account identifier which identifies the PayPal account.
    ///
    /// Length: 13. Pattern: `^[2-9A-HJ-NP-Z]{13}$`.
    public let payer: String?
    
    /// This field contains the total available balances based on currency.
    public var available: [CurrencyCodeAmount]?
    
    /// This field contains the total pending reversal balances based on currency.
    public var pending: [CurrencyCodeAmount]?
    
    enum CodingKeys: String, CodingKey {
        case payer = "payer_id"
        case available = "available_balances"
        case pending = "pending_balances"
    }
}
