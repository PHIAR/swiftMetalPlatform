import swiftVulkan
import vulkan
import Foundation
import MetalProtocols

internal final class VkMetalTexture: VkMetalResource,
                                     Texture {
    private let image: VulkanImage
    private let deviceMemory: VulkanDeviceMemory?
    private let imageView: VulkanImageView?
    private let size: Size
    private let _mipmapLevelCount: Int
    private let _sampleCount: Int
    private let _arrayLength: Int

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
        return self.size.width
    }

    public var height: Int {
        return self.size.height
    }

    public var depth: Int {
        return self.size.depth
    }

    public var mipmapLevelCount: Int {
        return self._mipmapLevelCount
    }

    public var sampleCount: Int {
        return self._sampleCount
    }

    public var arrayLength: Int {
        return self._arrayLength
    }


    internal init(device: VkMetalDevice,
                  descriptor: TextureDescriptor,
                  image: VulkanImage,
                  deviceMemory: VulkanDeviceMemory? = nil) {
        let extent = VkExtent3D(width: UInt32(descriptor.width),
                                height: UInt32(descriptor.height),
                                depth: UInt32(max(1, descriptor.depth)))
        let viewType = descriptor.textureType.toVulkanImageViewType()
        let format = descriptor.pixelFormat.toVulkanFormat()
        let mipLevels = max(1, descriptor.mipmapLevelCount)
        let arrayLayers = max(1, descriptor.arrayLength)
        let _device = device.getDevice()
        var imageView: VulkanImageView? = nil

        if descriptor.usage.contains(.renderTarget) {
            let aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
            let subresourceRange = VkImageSubresourceRange(aspectMask: aspectMask,
                                                           baseMipLevel: 0,
                                                           levelCount: UInt32(mipLevels),
                                                           baseArrayLayer: 0,
                                                           layerCount: UInt32(arrayLayers))

            imageView = _device.createImageView(image: image,
                                                viewType: viewType,
                                                format: format,
                                                subresourceRange: subresourceRange)
        }

        self.image = image
        self.deviceMemory = deviceMemory
        self.imageView = imageView
        self.size = Size(width: Int(extent.width),
                         height: Int(extent.height),
                         depth: Int(extent.depth))
        self._mipmapLevelCount = mipLevels
        self._sampleCount = 1
        self._arrayLength = arrayLayers
        super.init(device: device)
    }

    internal convenience init(device: VkMetalDevice,
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
        let _device = device.getDevice()
        let image = _device.createImage(flags: flags,
                                        imageType: imageType,
                                        format: format,
                                        extent: extent,
                                        mipLevels: mipLevels,
                                        arrayLayers: arrayLayers,
                                        usage: VK_IMAGE_USAGE_TRANSFER_DST_BIT.rawValue,
                                        queueFamilies: queueFamilies)
        let imageMemoryRequirements = image.getImageMemoryRequirements()
        let deviceMemory = _device.allocateMemory(size: Int(imageMemoryRequirements.size),
                                                  memoryTypeIndex: 0)

        image.bindImageMemory(deviceMemory: deviceMemory,
                              offset: 0)
        self.init(device: device,
                  descriptor: descriptor,
                  image: image)
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
