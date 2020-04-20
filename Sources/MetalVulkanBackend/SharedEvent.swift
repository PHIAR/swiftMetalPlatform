import MetalProtocols

internal final class VkMetalSharedEvent: VkMetalEvent,
                                         SharedEvent {
    public var signaledValue: UInt64 {
        get {
            return 0
        }

        set {
        }
    }

    public func makeSharedEventHandle() -> SharedEventHandle {
        return SharedEventHandle()
    }

    public func notify(_ listener: SharedEventListener,
                       atValue value: UInt64,
                       block: @escaping SharedEvent.NotificationBlock) {
    }
}
