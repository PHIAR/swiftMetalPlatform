import MetalProtocols

internal final class VkMetalBlitCommandEncoder: VkMetalCommandEncoder,
                                                BlitCommandEncoder {

    public func copy(from: Buffer,
                     sourceOffset: Int,
                     to: Buffer,
                     destinationOffset: Int,
                     size: Int) {
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
    }

    public func fill(buffer: Buffer,
                     range: Range <Int>,
                     value: UInt8) {
    }

    public func generateMipmaps(for: Texture) {
    }
}
