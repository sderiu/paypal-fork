import Vapor

/// An interval unit, specifying the length of a time interval,
/// i.e. every _n_ `day`.
public enum Frequency: String, Hashable, CaseIterable, Content {
    
    /// The interval is how often in days an action should occur.
    case day = "DAY"
    
    /// The interval is how often in weeks an action should occur.
    case week = "WEEK"
    
    /// The interval is how often in monthes an action should occur.
    case month = "MONTH"
    
    /// The interval is how often in years an action should occur.
    case year = "YEAR"
    
    public init(from decoder: Decoder)throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self).uppercased()
        guard let freq = Frequency.init(rawValue: raw) else {
            throw PayPalError(status: .badRequest, identifier: "badCase", reason: "Cannot get `Frequency` case from value '\(raw)'")
        }
        self = freq
    }
}
