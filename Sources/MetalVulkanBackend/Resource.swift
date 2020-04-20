import MetalProtocols

internal class VkMetalResource: VkMetalObject,
                                Resource {
    public var allocatedSize: Int {
        return 0
    }

    internal override init(device: VkMetalDevice) {
        super.init(device: device)
    }

    deinit {
    }

    public var storageMode: StorageMode {
        return .shared
    }
}
