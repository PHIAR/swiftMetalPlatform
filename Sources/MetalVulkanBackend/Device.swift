import swiftVulkan
import vulkan
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

internal extension PixelFormat {
    private static let formatMappings: [PixelFormat: VulkanFormat] = [
        .bgra8Unorm: .bgra8Unorm,
    ]

    func toVulkanFormat() -> VulkanFormat {
        return PixelFormat.formatMappings[self]!
    }
}

internal extension TextureType {
    private static let imageTypeMappings: [TextureType: VulkanImageType] = [
        .type1D: .type1D,
        .type2D: .type2D,
        .type3D: .type3D,
        .typeCube: .type2D,
    ]

    func toVulkanImageType() -> VulkanImageType {
        return TextureType.imageTypeMappings[self]!
    }
}

internal final class VkMetalDevice: Device {
    internal static let instance: VulkanInstance? = {
        var extensions = [
            "VK_KHR_get_physical_device_properties2",
            "VK_KHR_surface",
        ]

    #if os(Android)
        extensions.append("VK_KHR_android_surface")
    #elseif os(Linux)
        extensions.append("VK_KHR_xlib_surface")
    #endif

        return VulkanInstance(extensions: extensions)
    }()

    private let deviceMemBaseAddrAlign: Int
    private let queueFamily: Int
    private let deviceQueue: VulkanQueue
    private let descriptorPool: VulkanDescriptorPool

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
        let queueFamily = 0

        precondition(!queueFamilyProperties.isEmpty)

        var features = VkPhysicalDeviceFeatures()

        features.shaderInt16 = VkBool32(VK_TRUE)

        var extensions: [String] = [
            "VK_KHR_storage_buffer_storage_class",
        ]

    #if os(Android)
    #else
        extensions += [
            "VK_KHR_8bit_storage",
            "VK_KHR_shader_float16_int8",
        ]
    #endif

        let device = physicalDevice.createDevice(queues: [ queueFamily ],
                                                 layerNames: [],
                                                 extensions: extensions,
                                                 features: features)
        let maxDescriptorSets = 128
        let poolSizes = [
            VkDescriptorPoolSize(type: VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
                                 descriptorCount: 128),
            VkDescriptorPoolSize(type: VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                 descriptorCount: 128),
            VkDescriptorPoolSize(type: VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                 descriptorCount: 128),
        ]

        let descriptorPool = device.createDescriptorPool(flags: VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT.rawValue,
                                                         maxSets: maxDescriptorSets,
                                                         poolSizes: poolSizes)

        self.physicalDevice = physicalDevice
        self.device = device
        self.queueFamily = queueFamily
        self.deviceQueue = device.getDeviceQueue(queueFamily: queueFamily,
                                                 queue: 0)
        self.descriptorPool = descriptorPool
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
        let commandPool = self.device.createCommandPool(queue: self.queueFamily)

        return VkMetalCommandQueue(device: self,
                                   deviceQueue: self.deviceQueue,
                                   descriptorPool: self.descriptorPool,
                                   commandPool: commandPool,
                                   maxCommandBufferCount: maxCommandBufferCount)
    }

    public func makeComputePipelineState(function: Function) throws -> ComputePipelineState {
        let _function = function as! VkMetalFunction

        guard let computePipelineState = VkMetalComputePipelineState(device: self.device,
                                                                     function: _function) else {
            throw ComputePipelineStateError.failed
        }

        return computePipelineState
    }

    public func makeDefaultLibrary() -> Library? {
        return try? self.makeDefaultLibrary(bundle: Bundle.main)
    }

    public func makeDefaultLibrary(bundle: Bundle) throws -> Library {
        guard let shaderURLs = bundle.urls(forResourcesWithExtension: "spv",
                                           subdirectory: "spirv") else {
            preconditionFailure()
        }

        var shaders: [String: [UInt32]] = [:]

        try shaderURLs.forEach { shaderURL in
        #if os(iOS) || os(macOS) || os(tvOS)
            guard let name = shaderURL.lastPathComponent.split(separator: ".").first else {
                return
            }
        #else
            guard let name = shaderURL.lastPathComponent?.split(separator: ".").first else {
                return
            }
        #endif

            shaders[String(name)] = try Data(contentsOf: shaderURL as URL).withUnsafeBytes {
                return Array(UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: UInt32.self),
                                                 count: $0.count / MemoryLayout <UInt32>.size))
            }
        }

        return VkMetalLibrary(device: self,
                              shaders: shaders)
    }

    public func makeEvent() -> Event? {
        return VkMetalEvent(device: self)
    }

    public func makeHeap(descriptor: HeapDescriptor) -> Heap? {
        return VkMetalHeap(device: self,
                           descriptor: descriptor)
    }

    public func makeLibrary(data: __DispatchData) throws -> Library {
        let _data = data as DispatchData

        return _data.withUnsafeBytes { (pointer: UnsafePointer <UInt8>) in
            let spirv = UnsafeBufferPointer(start: UnsafeRawPointer(pointer).assumingMemoryBound(to: UInt32.self),
                                            count: MemoryLayout <UInt32>.size)

            return self.makeLibrary(spirv: Array(spirv))
        }
    }

    public func makeLibrary(filepath: String) throws -> Library {
        let _data = try Data(contentsOf: URL(fileURLWithPath: filepath))
        let data = _data.withUnsafeBytes { DispatchData(bytes: UnsafeRawBufferPointer(start: $0.baseAddress!,
                                                                                      count: _data.count)) as __DispatchData }

        return try self.makeLibrary(data: data)
    }

    public func makeLibrary(source: String,
                            options: CompileOptions?) throws -> Library {
        preconditionFailure("Use makeLibrary(spirv:) instead.")
    }

    public func makeLibrary(spirv: [UInt32]) -> Library {
        precondition(!spirv.isEmpty)

        return self.makeLibrary(spirv: spirv,
                                functionArgumentTypes: [])
    }

    public func makeLibrary(spirv: [UInt32],
                            functionArgumentTypes: FunctionArgumentTypes) -> Library {
        precondition(!spirv.isEmpty)

        return VkMetalLibrary(device: self,
                              shaders: [
            "": spirv,
        ],
                              functionsArgumentTypes: [
            "": functionArgumentTypes,
        ])
    }

    public func makeLibrary(URL: URL) throws -> Library {
        let _data = try Data(contentsOf: URL)
        let data = _data.withUnsafeBytes { DispatchData(bytes: UnsafeRawBufferPointer(start: $0.baseAddress!,
                                                                                      count: _data.count)) as __DispatchData }

        return try self.makeLibrary(data: data)
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
        let flags = {
            return ((descriptor.textureType == .typeCube) ? VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT.rawValue : 0)
        }()
        let extent = VkExtent3D(width: UInt32(descriptor.width),
                                height: UInt32(descriptor.height),
                                depth: UInt32(max(1, descriptor.depth)))
        let imageType = descriptor.textureType.toVulkanImageType()
        let format = descriptor.pixelFormat.toVulkanFormat()
        let mipLevels = max(1, descriptor.mipmapLevelCount)
        let arrayLayers = max(1, descriptor.arrayLength)
        let image = self.device.createImage(flags: flags,
                                            imageType: imageType,
                                            format: format,
                                            extent: extent,
                                            mipLevels: mipLevels,
                                            arrayLayers: arrayLayers,
                                            usage: VK_IMAGE_USAGE_TRANSFER_DST_BIT.rawValue,
                                            queueFamilies: [ self.queueFamily ])

        return VkMetalTexture(device: self,
                              image: image)
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

public extension Device {
    var vulkanInstance: VulkanInstance? {
        return VkMetalDevice.instance
    }
}
