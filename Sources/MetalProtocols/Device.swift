import Foundation

public enum FunctionArgumentType: Int {
    case unknown
    case buffer
    case constant
    case image
    case sampler
}

public typealias FunctionArgumentTypes = [FunctionArgumentType]

public protocol Device: class {
    var isHeadless: Bool { get }
    var isLowPower: Bool { get }
    var isRemovable: Bool { get }
    var name: String { get }
    var registryID: UInt64 { get }

    var maxBufferLength: Int { get }
    var maxThreadgroupMemoryLength: Int { get }
    var maxThreadsPerThreadgroup: Size { get }

    func makeBuffer(length: Int,
                    options: ResourceOptions) -> Buffer?

    func makeBuffer(bytes: UnsafeRawPointer,
                    length: Int) -> Buffer?

    func makeBuffer(bytes: UnsafeRawPointer,
                    length: Int,
                    options: ResourceOptions) -> Buffer?

    func makeBuffer(bytesNoCopy: UnsafeMutableRawPointer,
                    length: Int,
                    options: ResourceOptions,
                    deallocator: ((UnsafeMutableRawPointer, Int) -> Void)?) -> Buffer?

    func makeCommandQueue() -> CommandQueue?

    func makeCommandQueue(maxCommandBufferCount: Int) -> CommandQueue?

    func makeComputePipelineState(function: Function) throws -> ComputePipelineState

    func makeDefaultLibrary() -> Library?

    func makeDefaultLibrary(bundle: Bundle) throws -> Library

    func makeDepthStencilState(descriptor: DepthStencilDescriptor) -> DepthStencilState?

    func makeEvent() -> Event?

    func makeHeap(descriptor: HeapDescriptor) -> Heap?

    func makeLibrary(data: __DispatchData) throws -> Library

    func makeLibrary(data: Data) throws -> Library

    func makeLibrary(filepath: String) throws -> Library

    func makeLibrary(source: String,
                     options: CompileOptions?) throws -> Library

    func makeLibrary(spirv: [UInt32]) -> Library

    func makeLibrary(spirv: [UInt32],
                     functionArgumentTypes: [String: FunctionArgumentTypes]) -> Library

    func makeLibrary(URL: URL) throws -> Library

    func makeRenderPipelineState(descriptor: RenderPipelineDescriptor) throws -> RenderPipelineState

    func makeSamplerState(descriptor: SamplerDescriptor) -> SamplerState?

    func makeSharedEvent() -> SharedEvent?

    func makeSharedEvent(handle sharedEventHandle: SharedEventHandle) -> SharedEvent?

    func makeTexture(descriptor: TextureDescriptor) -> Texture?

    func supportsFeatureSet(_ featureSet: FeatureSet) -> Bool
}
