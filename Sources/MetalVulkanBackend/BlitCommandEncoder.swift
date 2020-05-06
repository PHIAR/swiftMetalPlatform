import vulkan
import swiftVulkan
import MetalProtocols

internal final class VkMetalBlitCommandEncoder: VkMetalCommandEncoder,
                                                BlitCommandEncoder {

    public func copy(from sourceBuffer: Buffer,
                     sourceOffset: Int,
                     to destinationBuffer: Buffer,
                     destinationOffset: Int,
                     size: Int) {
        let _sourceBuffer = sourceBuffer as! VkMetalBuffer
        let _destinationBuffer = destinationBuffer as! VkMetalBuffer
        let region = VkBufferCopy(srcOffset: VkDeviceSize(sourceOffset),
                                  dstOffset: VkDeviceSize(destinationOffset),
                                  size: VkDeviceSize(size))
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.copyBuffer(srcBuffer: _sourceBuffer.getBuffer(),
                                 dstBuffer: _destinationBuffer.getBuffer(),
                                 regions: [ region ])
        self.commandBuffer.addTrackedResource(resource: _sourceBuffer)
        self.commandBuffer.addTrackedResource(resource: _destinationBuffer)
    }

    public func copy(from sourceBuffer: Buffer,
                     sourceOffset: Int,
                     sourceBytesPerRow: Int,
                     sourceBytesPerImage: Int,
                     sourceSize: Size,
                     to destinationTexture: Texture,
                     destinationSlice: Int,
                     destinationLevel: Int,
                     destinationOrigin: Origin) {
        let _sourceBuffer = sourceBuffer as! VkMetalBuffer
        let _destinationTexture = destinationTexture as! VkMetalTexture
        let imageSubresource = VkImageSubresourceLayers(aspectMask: VK_IMAGE_ASPECT_COLOR_BIT.rawValue,
                                                        mipLevel: UInt32(destinationLevel),
                                                        baseArrayLayer: UInt32(destinationSlice),
                                                        layerCount: 1)
        let imageOffset = VkOffset3D(x: Int32(destinationOrigin.x),
                                     y: Int32(destinationOrigin.y),
                                     z: Int32(destinationOrigin.z))
        let imageExtent = VkExtent3D(width: UInt32(sourceSize.width),
                                     height: UInt32(sourceSize.height),
                                     depth: UInt32(sourceSize.depth))
        let region = VkBufferImageCopy(bufferOffset: VkDeviceSize(sourceOffset),
                                       bufferRowLength: UInt32(sourceSize.width),
                                       bufferImageHeight: UInt32(sourceSize.height),
                                       imageSubresource: imageSubresource,
                                       imageOffset: imageOffset,
                                       imageExtent: imageExtent)
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        _destinationTexture.transitionTo(layout: .transferDstOptimal,
                                         commandBuffer: commandBuffer)
        commandBuffer.copyBufferToImage(srcBuffer: _sourceBuffer.getBuffer(),
                                        dstImage: _destinationTexture.getImage(),
                                        dstImageLayout: _destinationTexture.getLayout(),
                                        regions: [ region ])
        self.commandBuffer.addTrackedResource(resource: _sourceBuffer)
        self.commandBuffer.addTrackedResource(resource: _destinationTexture)
    }

    public func copy(from sourceTexture: Texture,
                     sourceSlice: Int,
                     sourceLevel: Int,
                     sourceOrigin: Origin,
                     sourceSize: Size,
                     to destinationBuffer: Buffer,
                     destinationOffset: Int,
                     destinationBytesPerRow: Int,
                     destinationBytesPerImage: Int) {
        let _sourceTexture = sourceTexture as! VkMetalTexture
        let _destinationBuffer = destinationBuffer as! VkMetalBuffer
        let imageSubresource = VkImageSubresourceLayers(aspectMask: VK_IMAGE_ASPECT_COLOR_BIT.rawValue,
                                                        mipLevel: UInt32(sourceLevel),
                                                        baseArrayLayer: UInt32(sourceSlice),
                                                        layerCount: 1)
        let imageOffset = VkOffset3D(x: Int32(sourceOrigin.x),
                                     y: Int32(sourceOrigin.y),
                                     z: Int32(sourceOrigin.z))
        let imageExtent = VkExtent3D(width: UInt32(sourceSize.width),
                                     height: UInt32(sourceSize.height),
                                     depth: UInt32(sourceSize.depth))
        let region = VkBufferImageCopy(bufferOffset: VkDeviceSize(destinationOffset),
                                       bufferRowLength: UInt32(sourceSize.width),
                                       bufferImageHeight: UInt32(sourceSize.height),
                                       imageSubresource: imageSubresource,
                                       imageOffset: imageOffset,
                                       imageExtent: imageExtent)
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        _sourceTexture.transitionTo(layout: .transferSrcOptimal,
                                    commandBuffer: commandBuffer)
        commandBuffer.copyImageToBuffer(srcImage: _sourceTexture.getImage(),
                                        srcImageLayout: _sourceTexture.getLayout(),
                                        dstBuffer: _destinationBuffer.getBuffer(),
                                        regions: [ region ])
        self.commandBuffer.addTrackedResource(resource: _sourceTexture)
        self.commandBuffer.addTrackedResource(resource: _destinationBuffer)
    }

    public func copy(from sourceTexture: Texture,
                     to destinationTexture: Texture) {
        let _sourceTexture = sourceTexture as! VkMetalTexture
        let _destinationTexture = destinationTexture as! VkMetalTexture
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        _sourceTexture.transitionTo(layout: .transferSrcOptimal,
                                    commandBuffer: commandBuffer)
        _destinationTexture.transitionTo(layout: .transferDstOptimal,
                                         commandBuffer: commandBuffer)
        self.commandBuffer.addTrackedResource(resource: _sourceTexture)
        self.commandBuffer.addTrackedResource(resource: _destinationTexture)
    }

    public func copy(from sourceTexture: Texture,
                     sourceSlice: Int,
                     sourceLevel: Int,
                     to destinationTexture: Texture,
                     destinationSlice: Int,
                     destinationLevel: Int,
                     sliceCount: Int,
                     levelCount: Int) {
        let _sourceTexture = sourceTexture as! VkMetalTexture
        let _destinationTexture = destinationTexture as! VkMetalTexture
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        _sourceTexture.transitionTo(layout: .transferSrcOptimal,
                                    commandBuffer: commandBuffer)
        _destinationTexture.transitionTo(layout: .transferDstOptimal,
                                         commandBuffer: commandBuffer)
        self.commandBuffer.addTrackedResource(resource: _sourceTexture)
        self.commandBuffer.addTrackedResource(resource: _destinationTexture)
    }

    public func copy(from sourceTexture: Texture,
                     sourceSlice: Int,
                     sourceLevel: Int,
                     sourceOrigin: Origin,
                     sourceSize: Size,
                     to destinationTexture: Texture,
                     destinationSlice: Int,
                     destinationLevel: Int,
                     destinationOrigin: Origin) {
        let _sourceTexture = sourceTexture as! VkMetalTexture
        let _destinationTexture = destinationTexture as! VkMetalTexture
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        _sourceTexture.transitionTo(layout: .transferSrcOptimal,
                                    commandBuffer: commandBuffer)
        _destinationTexture.transitionTo(layout: .transferDstOptimal,
                                         commandBuffer: commandBuffer)
        self.commandBuffer.addTrackedResource(resource: _sourceTexture)
        self.commandBuffer.addTrackedResource(resource: _destinationTexture)
    }

    public func fill(buffer: Buffer,
                     range: Range <Int>,
                     value: UInt8) {
        let _buffer = buffer as! VkMetalBuffer
        let commandBuffer = self.commandBuffer.getCommandBuffer()
        let data = (UInt32(value) << 24) |
                   (UInt32(value) << 16) |
                   (UInt32(value) << 8) |
                   UInt32(value)

        commandBuffer.fillBuffer(dstBuffer: _buffer.getBuffer(),
                                 dstOffset: range.lowerBound,
                                 size: range.count,
                                 data: data)
        self.commandBuffer.addTrackedResource(resource: _buffer)
    }

    public func generateMipmaps(for sourceTexture: Texture) {
        let _sourceTexture = sourceTexture as! VkMetalTexture

        _sourceTexture.transitionTo(layout: .transferSrcOptimal,
                                    commandBuffer: commandBuffer.getCommandBuffer())
        self.commandBuffer.addTrackedResource(resource: _sourceTexture)
    }
}
