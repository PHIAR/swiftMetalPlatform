public protocol Heap {
    var storageMode: StorageMode { get }
    var cpuCacheMode: CPUCacheMode { get }
    var size: Int { get }
    var usedSize: Int { get }
    var currentAllocatedSize: Int { get }

    func makeBuffer(length: Int, options: ResourceOptions) -> Buffer?
    func makeTexture(descriptor: TextureDescriptor) -> Texture?
    func maxAvailableSize(alignment: Int) -> Int
}
