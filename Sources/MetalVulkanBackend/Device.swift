import swiftVulkan
import Foundation
import MetalProtocols

internal func MetalCopyAllDevices() -> [Device] {
    guard let device = MetalCreateSystemDefaultDevice() else {
        return []
    }

    return [ device ]
}

internal func MetalCreateSystemDefaultDevice() -> Device? {
    return VkMetalDevice()
}

internal final class VkMetalDevice: Device {
    internal static let instance: VulkanInstance? = {
        return VulkanInstance()
    }()

    private let deviceMemBaseAddrAlign: Int

    internal let physicalDevice: VulkanPhysicalDevice
    internal let device: VulkanDevice

    public var isHeadless: Bool {
        return true
    }

    public var isLowPower: Bool {
        return true
    }

    public var isRemovable: Bool {
        return true
    }

    public var name: String {
        var deviceName = self.physicalDevice.getPhysicalDeviceProperties().deviceName
        let name = String(cString: &deviceName.0)

        return name
    }

    public var registryID: UInt64 {
        return UInt64(self.physicalDevice.getPhysicalDeviceProperties().deviceID)
    }

    public var maxBufferLength: Int {
        let limits = self.physicalDevice.getPhysicalDeviceProperties().limits

        return Int(limits.maxStorageBufferRange)
    }

    public var maxThreadgroupMemoryLength: Int {
        let limits = self.physicalDevice.getPhysicalDeviceProperties().limits

        return Int(limits.maxComputeWorkGroupInvocations)
    }

    public var maxThreadsPerThreadgroup: Size {
        let limits = self.physicalDevice.getPhysicalDeviceProperties().limits

        return Size(width: Int(limits.maxComputeWorkGroupSize.0),
                    height: Int(limits.maxComputeWorkGroupSize.1),
                    depth: Int(limits.maxComputeWorkGroupSize.2))
    }

    fileprivate init?() {
        guard let instance = VkMetalDevice.instance else {
            return nil
        }

        let physicalDevices = instance.getPhysicalDevices()
        let physicalDevice = physicalDevices.first!
        let physicalDeviceProperties = physicalDevice.getPhysicalDeviceProperties()

        self.deviceMemBaseAddrAlign = Int(physicalDeviceProperties.limits.minMemoryMapAlignment)

        let queueFamilyProperties = physicalDevice.getQueueFamilyProperties()
        let queue = 0

        precondition(!queueFamilyProperties.isEmpty)

        let device = physicalDevice.createDevice(queues: [ queue ],
                                                 layerNames: [],
                                                 extensions: [])

        self.physicalDevice = physicalDevice
        self.device = device
    }

    deinit {
    }

    private func makeBuffer(length: Int,
                            options: ResourceOptions,
                            hostPointer: UnsafeRawPointer?,
                            deallocator: (() -> Void)?) -> Buffer? {
        return VkMetalBuffer(device: self,
                             length: length)
    }

    public func makeBuffer(length: Int,
                           options: ResourceOptions) -> Buffer? {
        return self.makeBuffer(length: length,
                               options: options,
                               hostPointer: nil,
                               deallocator: nil)
    }

    public func makeBuffer(bytes: UnsafeRawPointer,
                           length: Int,
                           options: ResourceOptions) -> Buffer? {
        return self.makeBuffer(length: length,
                               options: options,
                               hostPointer: bytes,
                               deallocator: nil)
    }

    public func makeBuffer(bytesNoCopy: UnsafeMutableRawPointer,
                           length: Int,
                           options: ResourceOptions,
                           deallocator: ((UnsafeMutableRawPointer, Int) -> Void)?) -> Buffer? {
        return self.makeBuffer(length: length,
                               options: options,
                               hostPointer: bytesNoCopy) {
            if let _deallocator = deallocator {
                _deallocator(bytesNoCopy, length)
            }
        }
    }

    public func makeCommandQueue() -> CommandQueue? {
        return self.makeCommandQueue(maxCommandBufferCount: 0)
    }

    public func makeCommandQueue(maxCommandBufferCount: Int) -> CommandQueue? {
        return VkMetalCommandQueue(device: self)
    }

    public func makeComputePipelineState(function: Function) throws -> ComputePipelineState {
        let _function = function as! VkMetalFunction

        guard let computePipelineState = VkMetalComputePipelineState(function: _function) else {
            throw ComputePipelineStateError.failed
        }

        return computePipelineState
    }

    public func makeDefaultLibrary() -> Library? {
        return try! VkMetalLibrary()
    }

    public func makeDefaultLibrary(bundle: Bundle) throws -> Library {
        return try! VkMetalLibrary()
    }

    public func makeEvent() -> Event? {
        return VkMetalEvent(device: self)
    }

    public func makeHeap(descriptor: HeapDescriptor) -> Heap? {
        return VkMetalHeap(device: self,
                           descriptor: descriptor)
    }

    public func makeLibrary(data: __DispatchData) throws -> Library {
        return try! VkMetalLibrary()
    }

    public func makeLibrary(filepath: String) throws -> Library {
        return try! VkMetalLibrary()
    }

    public func makeLibrary(source: String,
                            options: CompileOptions?) throws -> Library {
        var preprocessorOptions: String? = nil

        if let _options = options,
           let preprocessorMacros = _options.preprocessorMacros {
            preprocessorOptions = preprocessorMacros.map { "-D\($0.0)=\($0.1) " }.reduce("", +)
        }

        let library: VkMetalLibrary = try source.withCString {
            var _source: UnsafePointer <Int8>? = $0

            return try VkMetalLibrary(preprocessorOptions: preprocessorOptions)
        }

        return library
    }

    public func makeLibrary(URL: URL) throws -> Library {
        preconditionFailure()
    }

    public func makeRenderPipelineState(descriptor: RenderPipelineDescriptor) throws -> RenderPipelineState {
        return VkMetalRenderPipelineState()
    }

    public func makeSharedEvent() -> MTLSharedEvent? {
        return VkMetalSharedEvent(device: self)
    }

    public func makeSamplerState(descriptor: SamplerDescriptor) -> SamplerState? {
        return VkMetalSamplerState(device: self)
    }

    public func makeSharedEvent(handle sharedEventHandle: MTLSharedEventHandle) -> MTLSharedEvent? {
        return VkMetalSharedEvent(device: self)
    }

    public func makeTexture(descriptor: TextureDescriptor) -> Texture? {
        return VkMetalTexture(device: self)
    }

    func supportsFeatureSet(_ featureSet: FeatureSet) -> Bool {
        return true
    }
}

extension VkMetalDevice: CustomStringConvertible {
    var description: String {
        return ""
    }
}
