import MetalProtocols

internal class VkMetalEvent: VkMetalObject,
                             Event {
    internal override init(device: VkMetalDevice) {
        super.init(device: device)
    }

    deinit {
    }
}
