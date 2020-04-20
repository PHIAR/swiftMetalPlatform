public protocol BlitCommandEncoder: CommandEncoder {
    func copy(from: Buffer,
              sourceOffset: Int,
              to: Buffer,
              destinationOffset: Int,
              size: Int)

    func copy(from: Buffer,
              sourceOffset: Int,
              sourceBytesPerRow: Int,
              sourceBytesPerImage: Int,
              sourceSize: Size,
              to: Texture,
              destinationSlice: Int,
              destinationLevel: Int,
              destinationOrigin: Origin)

    func fill(buffer: Buffer,
              range: Range <Int>,
              value: UInt8)

    func generateMipmaps(for: Texture)
}
