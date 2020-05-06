import swiftVulkan
import vulkan
import Foundation
import MetalProtocols

internal final class VkMetalTexture: VkMetalResource,
                                     Texture {
    private let image: VulkanImage
    private let deviceMemory: VulkanDeviceMemory?
    private let imageView: VulkanImageView?
    private let _textureType: TextureType
    private let _pixelFormat: PixelFormat
    private let size: Size
    private let _mipmapLevelCount: Int
    private let _sampleCount: Int
    private let _arrayLength: Int
    private var layout: VulkanImageLayout = .undefined

    public override var description: String {
        return super.description + " type: \(self.textureType) format: \(self.pixelFormat) size: \(self.width)x\(self.height)x\(self.depth)))"
    }

    public var textureType: TextureType {
        return self._textureType
    }

    public var pixelFormat: PixelFormat {
        return self._pixelFormat
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
        let textureType = descriptor.textureType
        let viewType = textureType.toVulkanImageViewType()
        let pixelFormat = descriptor.pixelFormat
        let format = pixelFormat.toVulkanFormat()
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
        self._textureType = textureType
        self._pixelFormat = pixelFormat
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
        var usage = VK_IMAGE_USAGE_SAMPLED_BIT.rawValue |
                    VK_IMAGE_USAGE_TRANSFER_DST_BIT.rawValue |
                    VK_IMAGE_USAGE_TRANSFER_SRC_BIT.rawValue

        if descriptor.usage.contains(.renderTarget) {
            usage |= VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT.rawValue
        }

        let image = _device.createImage(flags: flags,
                                        imageType: imageType,
                                        format: format,
                                        extent: extent,
                                        mipLevels: mipLevels,
                                        arrayLayers: arrayLayers,
                                        tiling: VK_IMAGE_TILING_LINEAR,
                                        usage: usage,
                                        queueFamilies: queueFamilies)
        let imageMemoryRequirements = image.getImageMemoryRequirements()
        let deviceMemory = _device.allocateMemory(size: Int(imageMemoryRequirements.size),
                                                  memoryTypeIndex: 0)

        image.bindImageMemory(deviceMemory: deviceMemory,
                              offset: 0)
        self.init(device: device,
                  descriptor: descriptor,
                  image: image,
                  deviceMemory: deviceMemory)
    }

    internal func getImage() -> VulkanImage {
        return self.image
    }

    internal func getImageView() -> VulkanImageView? {
        return self.imageView
    }

    internal func getLayout() -> VulkanImageLayout {
        return self.layout
    }

    internal func transitionTo(layout: VulkanImageLayout,
                               commandBuffer: VulkanCommandBuffer) {
        guard self.layout != layout else {
            return
        }

        var srcAccessMask = VkAccessFlags(0)
        var dstAccessMask = VkAccessFlags(0)
        var srcStageMask = VkPipelineStageFlags(0)
        var dstStageMask = VkPipelineStageFlags(0)

        switch self.layout {
        case .colorAttachmentOptimal:
            srcAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT.rawValue
            srcStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue

        case .transferDstOptimal:
            srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT.rawValue
            srcStageMask = VK_PIPELINE_STAGE_TRANSFER_BIT.rawValue

        case .transferSrcOptimal:
            srcAccessMask = VK_ACCESS_TRANSFER_READ_BIT.rawValue
            srcStageMask = VK_PIPELINE_STAGE_TRANSFER_BIT.rawValue

        case .undefined:
            srcStageMask = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT.rawValue

        default:
            preconditionFailure()
        }

        switch layout {
        case .colorAttachmentOptimal:
            dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_READ_BIT.rawValue
            dstStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue

        case .transferDstOptimal:
            dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT.rawValue
            dstStageMask = VK_PIPELINE_STAGE_TRANSFER_BIT.rawValue

        case .transferSrcOptimal:
            dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT.rawValue
            dstStageMask = VK_PIPELINE_STAGE_TRANSFER_BIT.rawValue

        default:
            preconditionFailure()
        }

        let subResourceRange = VkImageSubresourceRange(aspectMask: VK_IMAGE_ASPECT_COLOR_BIT.rawValue,
                                                       baseMipLevel: 0,
                                                       levelCount: VK_REMAINING_MIP_LEVELS,
                                                       baseArrayLayer: 0,
                                                       layerCount: VK_REMAINING_ARRAY_LAYERS)
        let imageMemoryBarrier = VulkanImageMemoryBarrier(srcAccessMask: srcAccessMask,
                                                          dstAccessMask: dstAccessMask,
                                                          oldLayout: self.layout,
                                                          newLayout: layout,
                                                          srcQueueFamilyIndex: self._device.getQueueFamilyIndex(),
                                                          dstQueueFamilyIndex: self._device.getQueueFamilyIndex(),
                                                          image: self.image,
                                                          subresourceRange: subResourceRange)

        commandBuffer.pipelineBarrier(srcStageMask: srcStageMask,
                                      dstStageMask: dstStageMask,
                                      dependencyFlags: 0,
                                      memoryBarriers: [],
                                      bufferMemoryBarriers: [],
                                      imageMemoryBarriers: [
            imageMemoryBarrier,
        ])

        self.layout = layout
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

