import Foundation

#if !os(iOS) && !os(macOS) && !os(tvOS)
public typealias __DispatchData = DispatchData

public typealias CFTimeInterval = Double
#endif

public enum BlendFactor {
    case blendAlpha
    case blendColor
    case destinationAlpha
    case destinationColor
    case one
    case oneMinusBlendAlpha
    case oneMinusBlendColor
    case oneMinusDestinationAlpha
    case oneMinusDestinationColor
    case oneMinusSourceAlpha
    case oneMinusSource1Alpha
    case oneMinusSourceColor
    case oneMinusSource1Color
    case sourceAlpha
    case source1Alpha
    case sourceAlphaSaturated
    case sourceColor
    case source1Color
    case zero
}

public enum BlendOperation {
    case add
    case max
    case min
    case reverseSubtract
    case subtract
}

public enum CaptureDestination {
    case developerTools
    case gpuTraceDocument
}

public enum CompareFunction {
    case always
    case equal
    case greater
    case greaterEqual
    case less
    case lessEqual
    case never
    case notEqual
}

public enum CullMode {
    case none
    case back
    case front
}

public enum CPUCacheMode {
    case defaultCache
    case writeCombined
}

public enum DepthClipMode {
    case clamp
    case clip
}

public enum DispatchType {
    case concurrent
    case serial
}

public enum FeatureSet: UInt {
    case iOS_GPUFamily1_v1 = 0
    case iOS_GPUFamily1_v2 = 2
    case iOS_GPUFamily1_v3 = 5
    case iOS_GPUFamily1_v4 = 8
    case iOS_GPUFamily1_v5 = 12
    case iOS_GPUFamily2_v1 = 1
    case iOS_GPUFamily2_v2 = 3
    case iOS_GPUFamily2_v3 = 6
    case iOS_GPUFamily2_v4 = 9
    case iOS_GPUFamily2_v5 = 13
    case iOS_GPUFamily3_v1 = 4
    case iOS_GPUFamily3_v2 = 7
    case iOS_GPUFamily3_v3 = 10
    case iOS_GPUFamily3_v4 = 14
    case iOS_GPUFamily4_v1 = 11
    case iOS_GPUFamily4_v2 = 15
    case iOS_GPUFamily5_v1 = 16
    case tvOS_GPUFamily1_v1 = 30000
    case tvOS_GPUFamily1_v2 = 30001
    case tvOS_GPUFamily1_v3 = 30002
    case tvOS_GPUFamily1_v4 = 30004
    case tvOS_GPUFamily2_v1 = 30003
    case tvOS_GPUFamily2_v2 = 30005
    case macOS_GPUFamily1_v1 = 10000
    case macOS_GPUFamily1_v2 = 10001
    case macOS_GPUFamily1_v3 = 10003
    case macOS_GPUFamily1_v4 = 10004
    case macOS_GPUFamily2_v1 = 10005
    case macOS_ReadWriteTextureTier2 = 10002
}

public enum HazardTrackingMode {
    case `default`
    case tracked
    case untracked
}

public enum HeapType {
    case automatic
}

public enum IndexType {
    case uint16
    case uint32
}

public enum LanguageVersion {
    case defaultVersion

    case clVersion1_0
    case clVersion1_1
    case clVersion1_2
    case clVersion2_0
    case clVersion2_1

    case glslVersion_450

    case version1_0
    case version1_1
    case version1_2
    case version2_0
    case version2_1
    case version2_2
}

public enum LoadAction {
    case clear
    case dontCare
    case load
}

public enum PixelFormat: Int {
    case invalid
    case bgr10_xr
    case bgra8Unorm
    case bgrg422
    case r8Snorm
    case r8Unorm
    case r16Float
    case r32Float
    case rg16Float
    case rg32Float
    case rgba8Snorm
    case rgba8Unorm
    case rgba16Float
    case rgba32Float
}

public enum PrimitiveType {
    case line
    case lineStrip
    case point
    case triangle
    case triangleStrip
}

public enum PurgeableState: UInt {
    case keepCurrent = 1
    case nonVolatile = 2
    case volatile = 3
    case empty = 4
}

public enum SamplerAddressMode: UInt {
    case clampToEdge = 0
    case mirrorClampToEdge = 1
    case `repeat` = 2
    case mirrorRepeat = 3
    case clampToZero = 4
    case clampToBorderColor = 5
}

public enum SamplerBorderColor: UInt {
    case transparentBlack = 0
    case opaqueBlack = 1
    case opaqueWhite = 2
}

public enum SamplerMinMagFilter: UInt {
    case nearest = 0
    case linear = 1
}

public enum SamplerMipFilter: UInt {
    case notMipmapped = 0
}

public enum StencilOperation {
    case decrementClamp
    case decrementWrap
    case incrementClamp
    case incrementWrap
    case invert
    case keep
    case replace
    case zero
}

public enum StorageMode: Int {
    case managed = 0
    case memoryless = 1
    case `private` = 2
    case shared = 3
}

public enum StoreAction {
    case dontCare
    case multisampleResolve
    case store
    case storeAndMultisampleResolve
    case unknown
}

public enum TextureType {
    case unknown
    case type1D
    case type1DArray
    case type2D
    case type2DMultisample
    case type2DArray
    case type2DMultisampleArray
    case type3D
    case typeCube
    case typeCubeArray
    case typeTextureBuffer
}

public enum TriangleFillMode {
    case fill
    case lines
}

public enum VertexFormat {
    case invalid
    case char
    case char2
    case char3
    case char4
    case charNormalized
    case char2Normalized
    case char3Normalized
    case char4Normalized
    case float
    case float2
    case float3
    case float4
    case half
    case half2
    case half3
    case half4
    case int
    case int2
    case int3
    case int4
    case int1010102Normalized
    case short
    case short2
    case short3
    case short4
    case shortNormalized
    case short2Normalized
    case short3Normalized
    case short4Normalized
    case uchar
    case uchar2
    case uchar3
    case uchar4
    case ucharNormalized
    case uchar2Normalized
    case uchar3Normalized
    case uchar4Normalized
    case uchar4Normalized_bgra
    case uint
    case uint2
    case uint3
    case uint4
    case uint1010102Normalized
    case ushort
    case ushort2
    case ushort3
    case ushort4
    case ushortNormalized
    case ushort2Normalized
    case ushort3Normalized
    case ushort4Normalized
}

public enum VertexStepFunction {
    case constant
    case perInstance
    case perPatch
    case perPatchControlPoint
    case perVertex
}

public enum Winding {
    case clockwise
    case counterClockwise
}

public protocol Drawable {
    var texture: Texture { get }
    var layer: Layer { get }
}

public protocol Layer {
    var device: Device { get set }
    var drawableSize: Size { get set }
    var maximumDrawableCount: Int { get set }
    var pixelFormat: PixelFormat { get set }

    func nextDrawable() -> Drawable?
}

public struct ClearColor {
    public var red: Float
    public var green: Float
    public var blue: Float
    public var alpha: Float

    public init(red: Float = 0.0,
                green: Float = 0.0,
                blue: Float = 0.0,
                alpha: Float = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

public struct ColorWriteMask: OptionSet {
    public static let all = ColorWriteMask([ .red, .blue, .green, .alpha ])
    public static let none = ColorWriteMask([])
    public static let red = ColorWriteMask(rawValue: 0x8)
    public static let green = ColorWriteMask(rawValue: 0x4)
    public static let blue = ColorWriteMask(rawValue: 0x2)
    public static let alpha = ColorWriteMask(rawValue: 0x1)

    public var rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

public struct FunctionConstantValues {
    public init() {
    }
}

public struct Origin {
    public var x: Int
    public var y: Int
    public var z: Int

    public init(x: Int = 0,
                y: Int = 0,
                z: Int = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public struct Region {
    public var origin = Origin()
    public var size = Size()

    public init() {
    }

    public init(origin: Origin,
                size: Size) {
        self.origin = origin
        self.size = size
    }
}

public struct ResourceOptions: OptionSet {
    public var rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static var storageModeManaged = ResourceOptions(rawValue: UInt(StorageMode.managed.rawValue))

    public static var storageModeMemoryless = ResourceOptions(rawValue: UInt(StorageMode.memoryless.rawValue))

    public static var storageModePrivate = ResourceOptions(rawValue: UInt(StorageMode.`private`.rawValue))

    public static var storageModeShared = ResourceOptions(rawValue: UInt(StorageMode.shared.rawValue))
}

public struct ScissorRect {
    public var x = 0
    public var y = 0
    public var width = 0
    public var height = 0
}

public struct Size {
    public var width = 0
    public var height = 0
    public var depth = 0

    public init() {
    }

    public init(width: Int,
                height: Int,
                depth: Int) {
        self.width = width
        self.height = height
        self.depth = depth
    }
}

extension Size: Hashable {
    public func hash(to hasher: inout Hasher) {
        hasher.combine(self.width)
        hasher.combine(self.height)
        hasher.combine(self.depth)
    }
}

public struct TextureUsage: OptionSet {
    public let rawValue: Int

    public static let renderTarget = TextureUsage(rawValue: 1 << 0)
    public static let shaderRead = TextureUsage(rawValue: 1 << 1)
    public static let shaderWrite = TextureUsage(rawValue: 1 << 2)
    public static let pixelFormatView = TextureUsage(rawValue: 1 << 3)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct Viewport {
    public var originX: Double
    public var originY: Double
    public var width: Double
    public var height: Double
    public var znear: Double
    public var zfar: Double

    public init(originX: Double,
                originY: Double,
                width: Double,
                height: Double,
                znear: Double,
                zfar: Double) {
        self.originX = originX
        self.originY = originY
        self.width = width
        self.height = height
        self.znear = znear
        self.zfar = zfar
    }
}

public final class CaptureDescriptor {
    public var captureObject: AnyObject? = nil
    public var destination: CaptureDestination = .developerTools
    public var outputURL: URL? = nil

    public init() {
    }
}

public final class CaptureManager {
    private static let sharedInstance = CaptureManager()

    public static func shared() -> CaptureManager {
        return CaptureManager.sharedInstance
    }

    private init() {
    }

    public func makeCaptureScope(device: Device) -> CaptureScope {
        return CaptureScope(device: device)
    }

    public func makeCaptureScope(commandQueue: CommandQueue) -> CaptureScope {
        return CaptureScope(device: commandQueue.device)
    }

    public func startCapture(device: Device) {
    }

    public func startCapture(commandQueue: CommandQueue) {
    }

    public func startCapture(scope: CaptureScope) {
    }

    public func startCapture(with descriptor: CaptureDescriptor) throws {
    }

    public func stopCapture() {
    }
}

public final class CaptureScope {
    private let device: Device

    internal init(device: Device) {
        self.device = device
    }

    public func begin() {
    }

    public func end() {
    }
}

public final class CompileOptions {
    public var fastMathEnabled = false
    public var languageVersion = LanguageVersion.defaultVersion
    public var preprocessorMacros: [String: Any]?

    public init() {
    }
}

public final class DepthStencilDescriptor {
    public var depthCompareFunction: CompareFunction = .always
    public var isDepthWriteEnabled = false
    public var backFaceStencil = StencilDescriptor()
    public var frontFaceStencil = StencilDescriptor()
    public var label = ""

    public init() {
    }
}

public final class HeapDescriptor {
    private var _storageMode: StorageMode = .shared
    private var _cpuCacheMode: CPUCacheMode = .defaultCache
    private var _size = 0
    private var _hazardTrackingMode: HazardTrackingMode = .default

    public var storageMode: StorageMode {
        get {
            return self._storageMode
        }

        set {
            self._storageMode = newValue
        }
    }

    public var cpuCacheMode: CPUCacheMode {
        get {
            return self._cpuCacheMode
        }

        set {
            self._cpuCacheMode = newValue
        }
    }

    public var size: Int {
        get {
            return self._size
        }

        set {
            self._size = newValue
        }
    }

    public var hazardTrackingMode: HazardTrackingMode {
        get {
            return self._hazardTrackingMode
        }

        set {
            self._hazardTrackingMode = newValue
        }
    }

    public init() {
    }
}

public class RenderPassAttachmentDescriptor {
    public var texture: Texture? = nil
    public var loadAction: LoadAction = .dontCare
    public var storeAction: StoreAction = .dontCare
}

public class RenderPassColorAttachmentDescriptor: RenderPassAttachmentDescriptor {
    public var clearColor = ClearColor(red: 0.0,
                                       green: 0.0,
                                       blue: 0.0,
                                       alpha: 1.0)
}

public class RenderPassColorAttachmentDescriptorArray {
    public var attachments: [RenderPassColorAttachmentDescriptor] = []

    private func resizeAttachments(size: Int) {
        if size >= self.attachments.count {
            self.attachments += Array(repeating: RenderPassColorAttachmentDescriptor(),
                                      count: 1 + size - self.attachments.count)
        }
    }

    public subscript(index: Int) ->  RenderPassColorAttachmentDescriptor! {
        get {
            self.resizeAttachments(size: index)
            return self.attachments[index]
        }

        set {
            self.resizeAttachments(size: index)
            self.attachments[index] = newValue
        }
    }
}

public class RenderPassDepthAttachmentDescriptor: RenderPassAttachmentDescriptor {
    public override init() {
    }
}

public class RenderPassStencilAttachmentDescriptor: RenderPassAttachmentDescriptor {
    public override init() {
    }
}

public class RenderPassDescriptor: Equatable {
    public var colorAttachments = RenderPassColorAttachmentDescriptorArray()
    public var depthAttachment: RenderPassDepthAttachmentDescriptor!
    public var stencilAttachment: RenderPassStencilAttachmentDescriptor!
    public var renderTargetArrayLength = 0
    public var renderTargetWidth = 0
    public var renderTargetHeight = 0
    public var imageblockSampleLength = 0
    public var threadgroupMemoryLength = 0
    public var tileWidth = 0
    public var tileHeight = 0
    public var defaultRasterSampleCount = 0

    public static func == (lhs: RenderPassDescriptor,
                           rhs: RenderPassDescriptor) -> Bool {
        return false
    }

    public init() {
    }

    public func copy() -> Any {
        let renderPassDescriptor = RenderPassDescriptor()

        renderPassDescriptor.colorAttachments = self.colorAttachments
        renderPassDescriptor.depthAttachment = self.depthAttachment
        renderPassDescriptor.stencilAttachment = self.stencilAttachment
        renderPassDescriptor.renderTargetArrayLength = self.renderTargetArrayLength
        renderPassDescriptor.renderTargetWidth = self.renderTargetWidth
        renderPassDescriptor.renderTargetHeight = self.renderTargetHeight
        renderPassDescriptor.imageblockSampleLength = self.imageblockSampleLength
        renderPassDescriptor.threadgroupMemoryLength = self.threadgroupMemoryLength
        renderPassDescriptor.tileWidth = self.tileWidth
        renderPassDescriptor.tileHeight = self.tileHeight
        renderPassDescriptor.defaultRasterSampleCount = self.defaultRasterSampleCount
        return renderPassDescriptor
    }
}

public class RenderPipelineColorAttachmentDescriptor {
    public var pixelFormat: PixelFormat = .bgra8Unorm
    public var writeMask: ColorWriteMask = .all
    public var isBlendingEnabled = false
    public var rgbBlendOperation: BlendOperation = .add
    public var alphaBlendOperation: BlendOperation = .add
    public var destinationRGBBlendFactor: BlendFactor = .zero
    public var destinationAlphaBlendFactor: BlendFactor = .zero
    public var sourceRGBBlendFactor: BlendFactor = .one
    public var sourceAlphaBlendFactor: BlendFactor = .one
}

public class RenderPipelineColorAttachmentDescriptorArray {
    public var attachments: [RenderPipelineColorAttachmentDescriptor] = []

    private func resizeAttachments(size: Int) {
        if size >= self.attachments.count {
            self.attachments += Array(repeating: RenderPipelineColorAttachmentDescriptor(),
                                      count: 1 + size - self.attachments.count)
        }
    }

    public subscript(index: Int) ->  RenderPipelineColorAttachmentDescriptor! {
        get {
            self.resizeAttachments(size: index)
            return self.attachments[index]
        }

        set {
            self.resizeAttachments(size: index)
            self.attachments[index] = newValue
        }
    }
}

public final class RenderPipelineDescriptor: Equatable {
    public var vertexFunction: Function? = nil
    public var fragmentFunction: Function? = nil
    public var vertexDescriptor: VertexDescriptor? = nil
    public var colorAttachments = RenderPipelineColorAttachmentDescriptorArray()
    public var depthAttachmentPixelFormat: PixelFormat = .invalid
    public var stencilAttachmentPixelFormat: PixelFormat = .invalid
    public var sampleCount = 1
    public var isAlphaToCoverageEnabled = false
    public var isAlphaToOneEnabled = false
    public var isRasterizationEnabled = false
    public var rasterSampleCount = 1
    public var maxTessellationFactor = 16
    public var isTessellationFactorScaleEnabled = false
    public var tessellationOutputWindingOrder: Winding = .clockwise
    public var label = ""
    public var supportIndirectCommandBuffers = false
    public var maxVertexAmplificationCount = 0

    public static func == (lhs: RenderPipelineDescriptor,
                           rhs: RenderPipelineDescriptor) -> Bool {
        return false
    }

    public init() {
    }
}

public final class SamplerDescriptor: Equatable {
    public var normalizedCoordinates = true
    public var rAddressMode: SamplerAddressMode = .clampToEdge
    public var sAddressMode: SamplerAddressMode = .clampToEdge
    public var tAddressMode: SamplerAddressMode = .clampToEdge
    public var borderColor: SamplerBorderColor = .transparentBlack
    public var minFilter: SamplerMinMagFilter = .nearest
    public var magFilter: SamplerMinMagFilter = .nearest
    public var mipFilter: SamplerMipFilter = .notMipmapped
    public var lodMinClamp: Float = 0.0
    public var lodMaxClamp: Float = .greatestFiniteMagnitude
    public var lodAverage = false
    public var maxAnisotropy = 1

    public static func == (lhs: SamplerDescriptor,
                           rhs: SamplerDescriptor) -> Bool {
        return false
    }

    public init() {
    }

    public func copy() -> Any {
        let samplerDescriptor = SamplerDescriptor()

        samplerDescriptor.normalizedCoordinates = self.normalizedCoordinates
        samplerDescriptor.rAddressMode = self.rAddressMode
        samplerDescriptor.sAddressMode = self.sAddressMode
        samplerDescriptor.tAddressMode = self.tAddressMode
        samplerDescriptor.borderColor = self.borderColor
        samplerDescriptor.minFilter = self.minFilter
        samplerDescriptor.magFilter = self.magFilter
        samplerDescriptor.mipFilter = self.mipFilter
        samplerDescriptor.lodMinClamp = self.lodMinClamp
        samplerDescriptor.lodMaxClamp = self.lodMaxClamp
        samplerDescriptor.lodAverage = self.lodAverage
        samplerDescriptor.maxAnisotropy = self.maxAnisotropy
        return samplerDescriptor
    }
}

public final class SharedEventHandle {
    public init() {
    }
}

open class SharedEventListener {
    private let _dispatchQueue: DispatchQueue

    public var dispatchQueue: DispatchQueue {
        return self._dispatchQueue
    }

    public init() {
        self._dispatchQueue = .global()
    }

    public init(dispatchQueue: DispatchQueue) {
        self._dispatchQueue = dispatchQueue
    }
}

public final class StencilDescriptor {
    public var depthFailureOperation: StencilOperation = .keep
    public var depthStencilPassOperation: StencilOperation = .keep
    public var stencilCompareFunction: CompareFunction = .less
    public var stencilFailureOperation: StencilOperation = .keep
    public var readMask = UInt32(0xFFFFFFFF)
    public var writeMask = UInt32(0xFFFFFFFF)

    public init() {
    }
}

public final class TextureDescriptor {
    public class func texture2DDescriptor(pixelFormat: PixelFormat,
                                          width: Int,
                                          height: Int,
                                          mipmapped: Bool) -> TextureDescriptor {
        let descriptor = TextureDescriptor()

        descriptor.textureType = .type2D
        descriptor.pixelFormat = pixelFormat
        descriptor.width = width
        descriptor.height = height
        descriptor.mipmapLevelCount = mipmapped ? Int(ffs(min(Int32(width), Int32(height)))) : 1
        return descriptor
    }

    public var textureType: TextureType = .unknown
    public var pixelFormat: PixelFormat = .invalid
    public var width = 0
    public var height = 0
    public var depth = 0
    public var mipmapLevelCount = 0
    public var sampleCount = 0
    public var arrayLength = 0
    public var resourceOptions = ResourceOptions()
    public var cpuCacheMode: CPUCacheMode = .defaultCache
    public var storageMode: StorageMode = .shared
    public var allowGPUOptimizedContents = true
    public var usage: TextureUsage = [ .shaderRead ]

    public init() {
    }
}

public final class VertexAttributeDescriptor {
    public var format: VertexFormat = .invalid
    public var offset = 0
    public var bufferIndex = 0

    public init() {
    }
}

public final class VertexAttributeDescriptorArray {
    public var descriptors: [VertexAttributeDescriptor] = []

    private func resizeDescriptors(size: Int) {
        if size >= self.descriptors.count {
            self.descriptors += Array(repeating: VertexAttributeDescriptor(),
                                      count: 1 + size - self.descriptors.count)
        }
    }

    public subscript(index: Int) ->  VertexAttributeDescriptor! {
        get {
            self.resizeDescriptors(size: index)
            return self.descriptors[index]
        }

        set {
            self.resizeDescriptors(size: index)
            self.descriptors[index] = newValue
        }
    }
}

public final class VertexBufferLayoutDescriptor {
    public var stepFunction: VertexStepFunction = .perVertex
    public var stepRate = 1
    public var stride = 0

    public init() {
    }
}

public final class VertexBufferLayoutDescriptorArray {
    public var descriptors: [VertexBufferLayoutDescriptor] = []

    private func resizeDescriptors(size: Int) {
        if size >= self.descriptors.count {
            self.descriptors += Array(repeating: VertexBufferLayoutDescriptor(),
                                      count: 1 + size - self.descriptors.count)
        }
    }

    public subscript(index: Int) ->  VertexBufferLayoutDescriptor! {
        get {
            self.resizeDescriptors(size: index)
            return self.descriptors[index]
        }

        set {
            self.resizeDescriptors(size: index)
            self.descriptors[index] = newValue
        }
    }
}

public final class VertexDescriptor {
    public var attributes = VertexAttributeDescriptorArray()
    public var layouts = VertexBufferLayoutDescriptorArray()

    public init() {
    }

    public func reset() {
        self.attributes = VertexAttributeDescriptorArray()
        self.layouts = VertexBufferLayoutDescriptorArray()
    }
}

public func ClearColorMake(_ red: Double,
                           _ green: Double,
                           _ blue: Double,
                           _ alpha: Double) -> ClearColor {
    return ClearColor(red: Float(red),
                      green: Float(green),
                      blue: Float(blue),
                      alpha: Float(alpha))
}