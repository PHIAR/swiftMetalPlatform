import Dispatch
@_exported import MetalProtocols

public let MTLCopyAllDevices = MetalCopyAllDevices
public let MTLCreateSystemDefaultDevice = MetalCreateSystemDefaultDevice

public func MTLSizeMake(_ width: Int = 0,
                        _ height: Int = 0,
                        _ depth: Int = 0) -> MTLSize {
    return MTLSize(width: width,
                   height: height,
                   depth: depth)
}

public typealias MTLBlendFactor = BlendFactor
public typealias MTLBlendOperation = BlendOperation
public typealias MTLBlitCommandEncoder = BlitCommandEncoder
public typealias MTLBuffer = Buffer
public typealias MTLCaptureDescriptor = CaptureDescriptor
public typealias MTLCaptureManager = CaptureManager
public typealias MTLCaptureScope = CaptureScope
public typealias MTLColorWriteMask = ColorWriteMask
public typealias MTLCommandBuffer = CommandBuffer
public typealias MTLCommandEncoder = CommandEncoder
public typealias MTLCommandQueue = CommandQueue
public typealias MTLCompareFunction = CompareFunction
public typealias MTLCompileOptions = CompileOptions
public typealias MTLComputeCommandEncoder = ComputeCommandEncoder
public typealias MTLComputePipelineState = ComputePipelineState
public typealias MTLCullMode = CullMode
public typealias MTLCPUCacheMode = CPUCacheMode
public typealias MTLDepthStencilDescriptor = DepthStencilDescriptor
public typealias MTLDepthStencilState = DepthStencilState
public typealias MTLDevice = Device
public typealias MTLDrawable = Drawable
public typealias MTLEvent = Event
public typealias MTLFeatureSet = FeatureSet
public typealias MTLFunction = Function
public typealias MTLFunctionConstantValues = FunctionConstantValues
public typealias MTLHeap = Heap
public typealias MTLHeapDescriptor = HeapDescriptor
public typealias MTLHeapType = HeapType
public typealias MTLHazardTrackingMode = HazardTrackingMode
public typealias MTLIndexType = IndexType
public typealias MTLLibrary = Library
public typealias MTLLibraryError = LibraryError
public typealias MTLLoadAction = LoadAction
public typealias MTLOrigin = Origin
public typealias MTLPixelFormat = PixelFormat
public typealias MTLPrimitiveType = PrimitiveType
public typealias MTLPurgeableState = PurgeableState
public typealias MTLRegion = Region
public typealias MTLRenderCommandEncoder = RenderCommandEncoder
public typealias MTLRenderPassDescriptor = RenderPassDescriptor
public typealias MTLRenderPipelineDescriptor = RenderPipelineDescriptor
public typealias MTLRenderPipelineState = RenderPipelineState
public typealias MTLResource = Resource
public typealias MTLResourceOptions = ResourceOptions
public typealias MTLSamplerAddressMode = SamplerAddressMode
public typealias MTLSamplerBorderColor = SamplerBorderColor
public typealias MTLSamplerDescriptor = SamplerDescriptor
public typealias MTLSamplerMinMagFilter = SamplerMinMagFilter
public typealias MTLSamplerMipFilter = SamplerMipFilter
public typealias MTLSamplerState = SamplerState
public typealias MTLScissorRect = ScissorRect
public typealias MTLSize = Size
public typealias MTLSharedEvent = SharedEvent
public typealias MTLSharedEventHandle = SharedEventHandle
public typealias MTLSharedEventListener = VkMetalSharedEventListener
public typealias MTLSharedEventNotificationBlock = SharedEvent.NotificationBlock
public typealias MTLStencilDescriptor = StencilDescriptor
public typealias MTLStencilOperation = StencilOperation
public typealias MTLStorageMode = StorageMode
public typealias MTLStoreAction = StoreAction
public typealias MTLTexture = Texture
public typealias MTLTextureDescriptor = TextureDescriptor
public typealias MTLTextureType = TextureType
public typealias MTLTextureUsage = TextureUsage
public typealias MTLTriangleFillMode = TriangleFillMode
public typealias MTLVertexBufferLayoutDescriptor = VertexBufferLayoutDescriptor
public typealias MTLVertexDescriptor = VertexDescriptor
public typealias MTLViewport = Viewport
public typealias MTLWinding = Winding

#if os(macOS)
public extension CaptureManager {
    func makeCaptureScope(device: Device) -> CaptureScope {
        preconditionFailure()
    }

    func makeCaptureScope(commandQueue: CommandQueue) -> CaptureScope {
        preconditionFailure()
    }

    func startCapture(device: Device) {
        preconditionFailure()
    }

    func startCapture(commandQueue: CommandQueue) {
        preconditionFailure()
    }
}
#endif
