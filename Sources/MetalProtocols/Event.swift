public protocol Event {
    var device: Device { get }
    var label: String? { get nonmutating set }
}
