import swiftVulkan
import MetalProtocols

internal final class VkMetalTexture: VkMetalResource,
                                     Texture {
    private let image: VulkanImage

    public override var description: String {
        return super.description + " type: \(self.textureType) format: \(self.pixelFormat) size: \(self.width)x\(self.height)x\(self.depth)))"
    }

    public var textureType: TextureType {
        return .type2D
    }

    public var pixelFormat: PixelFormat {
        return .rgba8Unorm
    }

    public var width: Int {
        let _width = 0

        return _width
    }

    public var height: Int {
        let _height = 0

        return _height
    }

    public var depth: Int {
        let _depth = 0

        return min(1, _depth)
    }

    public var mipmapLevelCount: Int {
        return 1
    }

    public var sampleCount: Int {
        return 1
    }

    public var arrayLength: Int {
        return 1
    }

    internal init(device: VkMetalDevice,
                  image: VulkanImage) {
        self.image = image
        super.init(device: device)
    }

    internal func getImage() -> VulkanImage {
        return self.image
    }

    public func getBytes(_ pixelBytes: UnsafeMutableRawPointer,
                         bytesPerRow: Int,
                         from: Region,
                         mipmapLevel: Int) {
    }

    public func getBytes(_ pixelBytes: UnsafeMutableRawPointer,
                         bytesPerRow: Int,
                         bytesPerImage: Int,
                         from: Region,
                         mipmapLevel: Int,
                         slice: Int) {
    }

    public func replace(region: Region,
                        mipmapLevel: Int,
                        withBytes: UnsafeRawPointer,
                        bytesPerRow: Int) {
    }

    public func replace(region: Region,
                        mipmapLevel: Int,
                        slice: Int,
                        withBytes: UnsafeRawPointer,
                        bytesPerRow: Int,
                        bytesPerImage: Int) {
    }
}
