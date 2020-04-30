import swiftVulkan
import vulkan
import Foundation
import MetalProtocols

open class VisualLayer: VulkanVisualLayer,
                        Layer {
    private let device: Device

    private static func getQueueFamilyIndex(physicalDevice: VulkanPhysicalDevice,
                                            surface: VulkanSurface,
                                            flags: VkQueueFlags) -> Int {
        let queueFamilyProperties = physicalDevice.getQueueFamilyProperties()

        for i in 0..<queueFamilyProperties.count {
            let queueFamilyProperty = queueFamilyProperties[i]
            let supportsPresent = physicalDevice.isSurfaceSupported(surface: surface,
                                                                    onQueue: i)

            guard supportsPresent,
                  (queueFamilyProperty.queueFlags & flags) != 0 else {
                continue
            }

            return i
        }

        preconditionFailure()
    }

    public init(nativeWindowHandle: OpaquePointer) {
        let device = MetalCreateSystemDefaultDevice() as! VkMetalDevice
        let _device = device.device
        let physicalDevice = _device.getPhysicalDevice()
        let instance = physicalDevice.getInstance()
        let surface: VulkanSurface

    #if os(Android)
        surface = instance.createAndroidSurface(window: nativeWindowHandle)
    #elseif os(Linux)
        let display = XOpenDisplay(nil)!
        let window = Window(bitPattern: nativeWindowHandle)

        surface = instance.createXlibSurface(display: display,
                                             window: window)
    #else
        preconditionFailure()
    #endif

        let queueFamilyIndex = VisualLayer.getQueueFamilyIndex(physicalDevice: physicalDevice,
                                                               surface: surface,
                                                               flags: VkQueueFlags(VK_QUEUE_GRAPHICS_BIT.rawValue))

        self.device = device                                     

        super.init(device: _device,
                   queueFamilyIndex: queueFamilyIndex,
                   queueIndex: 0,
                   surface: surface)
    }

    public func getDevice() -> Device {
        return self.device
    }
}

