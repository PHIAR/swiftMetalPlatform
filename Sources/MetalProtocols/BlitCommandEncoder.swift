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

    func copy(from sourceTexture: Texture,
              sourceSlice: Int,
              sourceLevel: Int,
              sourceOrigin: Origin,
              sourceSize: Size,
              to destinationBuffer: Buffer,
              destinationOffset: Int,
              destinationBytesPerRow: Int,
              destinationBytesPerImage: Int)

    func copy(from sourceTexture: Texture,
              to destinationTexture: Texture)

    func copy(from sourceTexture: Texture,
              sourceSlice: Int,
              sourceLevel: Int,
              to destinationTexture: Texture,
              destinationSlice: Int,
              destinationLevel: Int,
              sliceCount: Int,
              levelCount: Int)

    func copy(from sourceTexture: Texture,
              sourceSlice: Int,
              sourceLevel: Int,
              sourceOrigin: Origin,
              sourceSize: Size,
              to destinationTexture: Texture,
              destinationSlice: Int,
              destinationLevel: Int,
              destinationOrigin: Origin)

    func fill(buffer: Buffer,
              range: Range <Int>,
              value: UInt8)

    func generateMipmaps(for: Texture)
}
