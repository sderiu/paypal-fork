import Vapor

/// An agreement for a recurring PayPal or debit card payment for goods or services.
public struct BillingAgreement: Content, Equatable {
    
    /// The PayPal-generated ID for the resource.
    ///
    /// Maximum length: 128.
    public let id: String?
    
    /// The state of the agreement.
    public let state: AgreementState?
    
    /// An array of request-related [HATEOAS links](https://developer.paypal.com/docs/api/overview/#hateoas-links).
    public let links: [LinkDescription]?
    
    /// The agreement name.
    ///
    /// Maximum length: 128.
    public var name: Optional128String
    
    /// The agreement description.
    ///
    /// Maximum length: 128.
    public var description: Optional128String
    
    /// The date and time when this agreement begins, in [Internet date and time format](https://tools.ietf.org/html/rfc3339#section-5.6).
    /// The start date must be no less than 24 hours after the current date as the agreement can take up to 24 hours to activate.
    ///
    /// The start date and time in the create agreement request might not match the start date and time that the API returns in the
    /// execute agreement response. When you execute an agreement, the API internally converts the start date and time to the start
    /// of the day in the time zone of the merchant account. For example, the API converts a `2017-01-02T14:36:21Z` start date and time
    /// for an account in the Berlin time zone (UTC + 1) to `2017-01-02T00:00:00`. When the API returns this date and time in the execute
    /// agreement response, it shows the converted date and time in the UTC time zone. So, the internal `2017-01-02T00:00:00` start date
    /// and time becomes `2017-01-01T23:00:00` externally.
    public var start: ISO8601Date?
    
    /// The agreement details.
    public var details: Details?
    
    /// The details for the customer who funds the payment. The API gathers this information from execution of the approval URL.
    public var payer: Payer?
    
    /// The shipping address of the agreement, which must be provided if it differs from the default address.
    public var shippingAddress: Address?
    
    /// The merchant preferences that override the default information in the plan. If you omit this parameter,
    /// the agreement uses the default merchant preferences from the plan. The merchant preferences include how much it costs to set up the agreement,
    /// the URLs where the customer can approve or cancel the agreement, the maximum number of allowed failed payment attempts, whether PayPal
    /// automatically bills the outstanding balance in the next billing cycle, and the action if the customer's initial payment fails.
    public var overrideMerchantPreferances: MerchantPreferances<CurrencyCodeAmount>?
    
    /// An array of charge models to override the charge models in the plan. A charge model defines shipping fee and tax information.
    /// If you omit this parameter, the agreement uses the default shipping fee and tax information from the plan.
    public var overrideChargeModels: [OverrideCharge]?
    
    /// The plan that can be used to create an agreement.
    public var plan: BillingPlan?
    
    /// Creates a new `BillingAgreement` instance.
    ///
    /// - Parameters:
    ///   - name: The agreement name.
    ///   - description: The agreement description.
    ///   - start: The date and time when this agreement begins, in Internet date and time format.
    ///   - details: The agreement details.
    ///   - payer: The details for the customer who funds the payment.
    ///   - shippingAddress: The shipping address of the agreement, which must be provided if it differs from the default address.
    ///   - overrideMerchantPreferances: The merchant preferences that override the default information in the plan.
    ///   - overrideChargeModels: An array of charge models to override the charge models in the plan.
    ///   - plan: The plan that can be used to create an agreement.
    public init(
        name: Optional128String,
        description: Optional128String,
        start: Date?,
        details: Details?,
        payer: Payer?,
        shippingAddress: Address?,
        overrideMerchantPreferances: MerchantPreferances<CurrencyCodeAmount>?,
        overrideChargeModels: [OverrideCharge]?,
        plan: BillingPlan?
    ) {
        self.id = nil
        self.state = nil
        self.links = nil
        
        self.name = name
        self.description = description
        self.start = start == nil ? nil : ISO8601Date(start!)
        self.details = details
        self.payer = payer
        self.shippingAddress = shippingAddress
        self.overrideMerchantPreferances = overrideMerchantPreferances
        self.overrideChargeModels = overrideChargeModels
        self.plan = plan
    }
    
    enum CodingKeys: String, CodingKey {
        case id, state, links, name, description, payer, plan
        case start = "start_date"
        case details = "agreement_details"
        case shippingAddress = "shipping_address"
        case overrideMerchantPreferances = "override_merchant_preferences"
        case overrideChargeModels = "override_charge_models"
    }
}
