import swiftVulkan
import MetalProtocols

internal final class VkMetalSharedEvent: VkMetalEvent,
                                         SharedEvent {
    private let semaphore: VulkanSemaphore

    public var signaledValue: UInt64 {
        get {
            return self.semaphore.getCounterValue()
        }

        set {
        }
    }

    public override init(device: VkMetalDevice) {
        self.semaphore = device.device.createSemaphore()
        super.init(device: device)
    }

    public func makeSharedEventHandle() -> SharedEventHandle {
        return SharedEventHandle()
    }

    public func notify(_ listener: SharedEventListener,
                       atValue value: UInt64,
                       block: @escaping SharedEvent.NotificationBlock) {
    }
}
