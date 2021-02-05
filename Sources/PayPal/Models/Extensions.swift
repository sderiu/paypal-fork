import Vapor

/// The extension properties for an `Activity` object.
public struct Extensions: Content, Equatable {
    
    /// The properties for a payment activity.
    public var paymentProperties: PaymentProperties?
    
    /// The money request activity.
    public var requestMoneyProperties: MoneyRequestProperties?
    
    /// The invoice activity properties.
    public var invoiceProperties: InvoiceProperties?
    
    /// The order activity-specific properties.
    public var orderProperties: OrderProperties?
    
    /// Creates a new `Extensions` instance.
    public init(
        paymentProperties: PaymentProperties?,
        requestMoneyProperties: MoneyRequestProperties?,
        invoiceProperties: InvoiceProperties?,
        orderProperties: OrderProperties?
    ) {
        self.paymentProperties = paymentProperties
        self.requestMoneyProperties = requestMoneyProperties
        self.invoiceProperties = invoiceProperties
        self.orderProperties = orderProperties
    }
    
    enum CodingKeys: String, CodingKey {
        case paymentProperties = "payment_properties"
        case requestMoneyProperties = "request_money_properties"
        case invoiceProperties = "invoice_properties"
        case orderProperties = "order_properties"
    }
}
