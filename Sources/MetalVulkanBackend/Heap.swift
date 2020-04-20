import MetalProtocols

internal final class VkMetalHeap: VkMetalObject,
                                  Heap {
    private let descriptor: HeapDescriptor

    public var storageMode: StorageMode {
        return self.descriptor.storageMode
    }

    public var cpuCacheMode: CPUCacheMode {
        return self.descriptor.cpuCacheMode
    }

    public var size: Int {
        return self.descriptor.size
    }

    public var usedSize: Int {
        return 0
    }

    public var currentAllocatedSize: Int {
        return 0
    }

    internal init(device: VkMetalDevice,
                  descriptor: HeapDescriptor) {
        self.descriptor = descriptor
        super.init(device: device)
    }

    public func makeBuffer(length: Int,
                           options: ResourceOptions) -> Buffer? {
        return self.device.makeBuffer(length: length,
                                      options: options)
    }

    public func makeTexture(descriptor: TextureDescriptor) -> Texture? {
        return self.device.makeTexture(descriptor: descriptor)
    }

    public func maxAvailableSize(alignment: Int) -> Int {
        return self.device.maxBufferLength
    }
}
