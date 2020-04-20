public protocol Texture: Resource {
    var textureType: TextureType { get }
    var pixelFormat: PixelFormat { get }
    var width: Int { get }
    var height: Int { get }
    var depth: Int { get }
    var mipmapLevelCount: Int { get }
    var sampleCount: Int { get }
    var arrayLength: Int { get }

    func getBytes(_ pixelBytes:UnsafeMutableRawPointer,
                  bytesPerRow: Int,
                  from: Region,
                  mipmapLevel: Int)

    func getBytes(_ pixelBytes:UnsafeMutableRawPointer,
                  bytesPerRow: Int,
                  bytesPerImage: Int,
                  from: Region,
                  mipmapLevel: Int,
                  slice: Int)

    func replace(region: Region,
                 mipmapLevel: Int,
                 withBytes: UnsafeRawPointer,
                 bytesPerRow: Int)

    func replace(region: Region,
                 mipmapLevel: Int,
                 slice: Int,
                 withBytes: UnsafeRawPointer,
                 bytesPerRow: Int,
                 bytesPerImage: Int)
}
