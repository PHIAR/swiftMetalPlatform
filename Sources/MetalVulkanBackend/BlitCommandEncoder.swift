import vulkan
import swiftVulkan
import MetalProtocols

internal final class VkMetalBlitCommandEncoder: VkMetalCommandEncoder,
                                                BlitCommandEncoder {

    public func copy(from: Buffer,
                     sourceOffset: Int,
                     to: Buffer,
                     destinationOffset: Int,
                     size: Int) {
        let _from = from as! VkMetalBuffer
        let _to = to as! VkMetalBuffer
        let region = VkBufferCopy(srcOffset: VkDeviceSize(sourceOffset),
                                  dstOffset: VkDeviceSize(destinationOffset),
                                  size: VkDeviceSize(size))
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.copyBuffer(srcBuffer: _from.getBuffer(),
                                 dstBuffer: _to.getBuffer(),
                                 regions: [ region ])
    }

    public func copy(from: Buffer,
                     sourceOffset: Int,
                     sourceBytesPerRow: Int,
                     sourceBytesPerImage: Int,
                     sourceSize: Size,
                     to: Texture,
                     destinationSlice: Int,
                     destinationLevel: Int,
                     destinationOrigin: Origin) {
        let _from = from as! VkMetalBuffer
        let _to = to as! VkMetalTexture
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
                                       bufferRowLength: UInt32(sourceBytesPerRow),
                                       bufferImageHeight: UInt32(sourceBytesPerImage /
                                                                 sourceBytesPerRow),
                                       imageSubresource: imageSubresource,
                                       imageOffset: imageOffset,
                                       imageExtent: imageExtent)
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.copyBufferToImage(srcBuffer: _from.getBuffer(),
                                        dstImage: _to.getImage(),
                                        dstImageLayout: VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                                        regions: [ region ])
    }

    public func fill(buffer: Buffer,
                     range: Range <Int>,
                     value: UInt8) {
        let _buffer = buffer as! VkMetalBuffer
        let commandBuffer = self.commandBuffer.getCommandBuffer()
        let data = UInt32(value << 24) |
                   UInt32(value << 16) |
                   UInt32(value << 8) |
                   UInt32(value)

        commandBuffer.fillBuffer(dstBuffer: _buffer.getBuffer(),
                                 dstOffset: range.lowerBound,
                                 size: range.count,
                                 data: data)
    }

    public func generateMipmaps(for: Texture) {
    }
}
