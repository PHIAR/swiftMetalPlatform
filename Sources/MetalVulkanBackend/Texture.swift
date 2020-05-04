import swiftVulkan
import vulkan
import Foundation
import MetalProtocols

internal final class VkMetalTexture: VkMetalResource,
                                     Texture {
    private let descriptor: TextureDescriptor
    private let image: VulkanImage
    private var imageView: VulkanImageView? = nil

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
                  descriptor: TextureDescriptor,
                  queueFamilies: [Int]) {
        let flags = {
            return ((descriptor.textureType == .typeCube) ? VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT.rawValue : 0)
        }()
        let extent = VkExtent3D(width: UInt32(descriptor.width),
                                height: UInt32(descriptor.height),
                                depth: UInt32(max(1, descriptor.depth)))
        let imageType = descriptor.textureType.toVulkanImageType()
        let format = descriptor.pixelFormat.toVulkanFormat()
        let mipLevels = max(1, descriptor.mipmapLevelCount)
        let arrayLayers = max(1, descriptor.arrayLength)
        let _device = device.device
        let image = _device.createImage(flags: flags,
                                        imageType: imageType,
                                        format: format,
                                        extent: extent,
                                        mipLevels: mipLevels,
                                        arrayLayers: arrayLayers,
                                        usage: VK_IMAGE_USAGE_TRANSFER_DST_BIT.rawValue,
                                        queueFamilies: queueFamilies)

        self.image = image
        self.descriptor = descriptor
        super.init(device: device)
    }

    internal func getImage() -> VulkanImage {
        return self.image
    }

    internal func getImageView() -> VulkanImageView? {
        return self.imageView
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
