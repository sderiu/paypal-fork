import Vapor
import JSON

/// You use billing plans and billing agreements to create an agreement for a recurring PayPal or debit card payment for goods or services.
///
/// A billing plan includes payment definitions and other details. A plan must include at least one regular payment definition
/// and, optionally, a trial payment definition. Each definition determines how often and for how long a customer is charged.
///
/// A plan can specify a type, which indicates whether the payment definitions in the plan have a fixed or infinite number of payment cycles.
/// The plan also defines merchant preferences including how much it costs to set up the agreement, the links where a customer can approve
/// or can cancel the agreement, and the action if the customer's initial payment fails.
///
/// By default, a plan is not active when you create it. To activate it, you update its `state` to ACTIVE.
///
/// For more information, see [Billing Plans and Agreements](https://developer.paypal.com/docs/integration/direct/billing-plans-and-agreements/).
///
/// - Warning: The use of the PayPal REST `/payments` APIs to accept credit card payments is restricted.
///   Instead, you can accept credit card payments with [Braintree Direct](https://www.braintreepayments.com/products/braintree-direct).
public final class BillingPlans: PayPalController {
    
    /// See `PayPalController.container`.
    public let container: Container
    
    /// Value is `"payments/billing-plans"`.
    ///
    /// See `PayPalController.resource` for more information.
    public let resource: String
    
    /// See `PayPalController.version`.
    public let version: Version
    
    /// See `PayPalController.init(container:)`.
    public init(container: Container) {
        self.container = container
        self.resource = "payments/billing-plans"
        self.version = try container.make(Configuration.self).version || .v1
    }
    
    
    /// Creates a billing plan. In the JSON request body, include the plan details. A plan must include at least one regular payment definition and,
    /// optionally, a trial payment definition. Each payment definition specifies a billing period, which determines how often and for how long the
    /// customer is charged. A plan can specify a fixed or infinite number of payment cycles. A payment definition can optionally specify shipping
    /// fee and tax amounts. The default state of a new plan is `CREATED`. Before you can create an agreement from a plan, you must activate the
    /// plan by updating its `state` to `ACTIVE`.
    ///
    /// A successful request returns the HTTP 201 Created status code and a JSON response body that shows plan details.
    ///
    /// - Parameter plan: The data for the new billing plan. The `.type` property must have a value before it is sent to the PayPal API.
    ///
    /// - Returns: The created billing plan wrapped in a future. If an error response was sent back instead, it gets converted
    ///   to a Swift error and the future wraps that instead.
    public func create(with plan: BillingPlan) -> Future<BillingPlan> {
        return self.client { client in
            guard plan.type != nil else { throw PayPalError(identifier: "nilValue", reason: "BillingPlan `type` value must not be `nil`.") }
            return client.post(self.path, body: plan, as: BillingPlan.self)
        }
    }
    
    /// Lists billing plans. To filter the plans that appear in the response, specify one or more optional query and pagination parameters.
    ///
    /// A successful request returns the HTTP `200 OK` status code and a JSON response body that lists plans with details.
    ///
    /// - Parameters:
    ///   - state: The state of the billing plans to fetch. PayPal uses `CREATED` if no value is passed in.
    ///   - parameters: The query-string paramaters passed in with the request. The values used for this
    ///   endpoint are `page`, `pageSize`, and `totalCountRequired`.
    ///
    /// - Returns: A list of the billing plans wrapped in a future. If an error response was sent back instead, it gets converted
    ///   to a Swift error and the future wraps that instead.
    public func list(state: BillingPlan.State? = nil, parameters: QueryParamaters = QueryParamaters()) -> Future<BillingPlan.List> {
        return self.client { client in
            var params = parameters
            
            if let state = state, params.custom == nil {
                params.custom = ["status": state.rawValue]
            } else {
                params.custom?["status"] = state?.rawValue
            }
            return client.get(self.path, parameters: params, as: BillingPlan.List.self)
        }
    }
    
    /// Updates fields in a billing plan, by ID. In the JSON request body, include a patch object that specifies the
    /// operation to perform, one or more fields to update, and a new value for each updated field.
    ///
    /// A successful request returns the HTTP `200 OK` status code with no JSON response body.
    ///
    /// - Parameters:
    ///   - plan: The ID of the billing plan to update.
    ///   - patches: An array of JSON patch objects to apply partial updates to resources.
    ///
    /// - Returns: The HTTP status of the response, in this case `200 OK`. If an error response was sent back instead,
    ///   it gets converted to a Swift error and the future wraps that instead.
    public func update(plan id: String, patches: [Patch]) -> Future<HTTPStatus> {
        return self.client { client in
            return client.patch(self.path + id, body: patches, as: HTTPStatus.self)
        }
    }
    
    /// Shows details for a billing plan, by ID.
    ///
    /// A successful request returns the HTTP `200 OK` status code and a JSON response body that shows plan details.
    ///
    /// - Parameter id: The ID of the billing plan for which to show details.
    ///
    /// - Returns: The billing plan for the ID passed in, wrapped in a future. If an error response was sent back instead,
    ///   it gets converted to a Swift error and the future wraps that instead.
    public func details(plan id: String) -> Future<BillingPlan> {
        return self.client { client in
            return client.get(self.path + id, as: BillingPlan.self)
        }
    }
    
    /// Sets the state of a billing plan, by ID.
    ///
    /// A successful request returns the HTTP `200 OK` status code with no JSON response body.
    ///
    /// - Parameters:
    ///   - plan: The ID of the billing plan to update.
    ///   - state: The new state to set the plan to.
    ///
    /// - Returns: The HTTP status of the response, in this case `200 OK`. If an error response was sent back instead,
    ///   it gets converted to a Swift error and the future wraps that instead.
    public func setState(of planID: String, to state: BillingPlan.State) -> Future<HTTPStatus> {
        let newValue = JSON.object(["state": .string(state.rawValue)])
        return self.update(plan: planID, patches: [ Patch(operation: .replace, path: "/", value: newValue) ])
    }
}
