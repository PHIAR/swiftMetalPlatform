public protocol SharedEvent: Event {
    typealias NotificationBlock = (SharedEvent, UInt64) -> Void

    var signaledValue: UInt64 { get set }

    func makeSharedEventHandle() -> SharedEventHandle
    func notify(_ listener: SharedEventListener,
                atValue value: UInt64,
                block: @escaping NotificationBlock)
}
