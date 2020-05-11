import swiftVulkan
import vulkan
import Foundation
import MetalProtocols

open class Visual: MetalProtocols.Drawable {
    private weak var _layer: VisualLayer?
    private let imageIndex: Int
    private let _texture: VkMetalTexture
    private let availabilitySemaphore: VulkanSemaphore
    private let renderFinishedSemaphore: VulkanSemaphore

    public var layer: Layer {
        return self._layer!
    }

    public var texture: Texture {
        return self._texture
    }

    internal init(layer: VisualLayer,
                  imageIndex: Int,
                  texture: VkMetalTexture,
                  availabilitySemaphore: VulkanSemaphore,
                  renderFinishedSemaphore: VulkanSemaphore) {
        self._layer = layer
        self.imageIndex = imageIndex
        self._texture = texture
        self.availabilitySemaphore = availabilitySemaphore
        self.renderFinishedSemaphore = renderFinishedSemaphore
    }

    internal func getAvailabilitySemaphore() -> VulkanSemaphore {
        return self.availabilitySemaphore
    }

    internal func getRenderFinishedSemaphore() -> VulkanSemaphore {
        return self.renderFinishedSemaphore
    }

    internal func enqueuePresentBarrier(commandBuffer: VkMetalCommandBuffer) {
        guard let layer = self._layer else {
            return
        }

        let device = layer.getDevice()
        let queueFamilyIndex = device.getQueueFamilyIndex()
        let swapchainImage = self._texture.getImage()
        let subResourceRange = VkImageSubresourceRange(aspectMask: VK_IMAGE_ASPECT_COLOR_BIT.rawValue,
                                                       baseMipLevel: 0,
                                                       levelCount: VK_REMAINING_MIP_LEVELS,
                                                       baseArrayLayer: 0,
                                                       layerCount: VK_REMAINING_ARRAY_LAYERS)
        let imageMemoryBarrier = VulkanImageMemoryBarrier(srcAccessMask: 0,
                                                          dstAccessMask: VK_ACCESS_TRANSFER_WRITE_BIT.rawValue,
                                                          oldLayout: .undefined,
                                                          newLayout: .transferDstOptimal,
                                                          srcQueueFamilyIndex: queueFamilyIndex,
                                                          dstQueueFamilyIndex: queueFamilyIndex,
                                                          image: swapchainImage,
                                                          subresourceRange: subResourceRange)
        let _commandBuffer = commandBuffer.getCommandBuffer()

        _commandBuffer.pipelineBarrier(srcStageMask: VK_PIPELINE_STAGE_TRANSFER_BIT.rawValue,
                                       dstStageMask: VK_PIPELINE_STAGE_TRANSFER_BIT.rawValue,
                                       dependencyFlags: 0,
                                       memoryBarriers: [],
                                       bufferMemoryBarriers: [],
                                       imageMemoryBarriers: [
            imageMemoryBarrier,
        ])
    }

    internal func present(commandBuffer: VkMetalCommandBuffer) {
        guard let layer = self._layer else {
            return
        }

        let imageIndex = self.imageIndex
        let availabilitySemaphore = self.availabilitySemaphore
        let renderFinishedSemaphore = self.renderFinishedSemaphore
        let frameFence = commandBuffer.getFence()
        let device = layer.getDevice()
        let deviceQueue = device.getDeviceQueue()
        let swapchain = layer.getSwapchain()

        deviceQueue.submit(waitSemaphores: [ availabilitySemaphore ],
                           waitDstStageMask: [ VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue ],
                           commandBuffers: [ commandBuffer.getCommandBuffer() ],
                           signalSemaphores: [ renderFinishedSemaphore ],
                           fence: frameFence)
        deviceQueue.present(waitSemaphores: [ renderFinishedSemaphore ],
                            swapchains: [ swapchain ],
                            imageIndices: [ imageIndex ])
    }
}

open class VisualLayer: Layer {
    private let nativeWindowHandle: OpaquePointer
    private var _reconfigureDevice = true
    private var _device: VkMetalDevice!
    private var commandQueue: VkMetalCommandQueue!
    private var _drawableSize = Size()
    private var _maximumDrawableCount = 2
    private var surface: VulkanSurface!
    private var _pixelFormat: PixelFormat = .bgra8Unorm
    private var extent = Size(width: 0,
                              height: 0,
                              depth: 1)
    private var swapchain: VulkanSwapchain!
    private var swapchainIndex = 0
    private var imageAvailableSemaphores: [VulkanSemaphore] = []
    private var renderFinishedSemaphores: [VulkanSemaphore] = []

    public var device: Device {
        get {
            dispatchPrecondition(condition: .onQueue(.main))

            return self._device
        }

        set {
            dispatchPrecondition(condition: .onQueue(.main))

            let _device = newValue as? VkMetalDevice

            self._reconfigureDevice = self._reconfigureDevice || (self._device !== _device)
            self._device = _device
        }
    }

    public var drawableSize: Size {
        get {
            dispatchPrecondition(condition: .onQueue(.main))

            return self._drawableSize
        }

        set {
            dispatchPrecondition(condition: .onQueue(.main))

            self._reconfigureDevice = self._reconfigureDevice || (self._drawableSize != newValue)
            self._drawableSize = newValue
        }
    }

    public var maximumDrawableCount: Int {
        get {
            dispatchPrecondition(condition: .onQueue(.main))

            return self._maximumDrawableCount
        }

        set {
            dispatchPrecondition(condition: .onQueue(.main))

            self._reconfigureDevice = self._reconfigureDevice || ( self._maximumDrawableCount != newValue)
            self._maximumDrawableCount = newValue
        }
    }

    public var pixelFormat: PixelFormat {
        get {
            dispatchPrecondition(condition: .onQueue(.main))

            return self._pixelFormat
        }

        set {
            dispatchPrecondition(condition: .onQueue(.main))

            self._reconfigureDevice = self._reconfigureDevice || (self._pixelFormat != newValue)
            self._pixelFormat = newValue
        }
    }

    private func reconfigureDeviceIfNeeded() {
        guard self._reconfigureDevice else {
            return
        }

        let device = MetalCreateSystemDefaultDevice() as! VkMetalDevice
        let physicalDevice = device.getPhysicalDevice()
        let instance = physicalDevice.getInstance()
        let surface: VulkanSurface

    #if os(macOS)
        surface = instance.createMacOSSurface(view: self.nativeWindowHandle)
    #elseif os(Android)
        surface = instance.createAndroidSurface(window: self.nativeWindowHandle)
    #elseif os(Linux)
        let display = XOpenDisplay(nil)!
        let window = Window(bitPattern: self.nativeWindowHandle)

        surface = instance.createXlibSurface(display: display,
                                             window: window)
    #else
        preconditionFailure()
    #endif

        let surfaceFormat = physicalDevice.getSurfaceFormats(surface: surface)[0]
        let surfaceCapabilities = physicalDevice.getSurfaceCapabilities(surface: surface)
        let extent = surfaceCapabilities.currentExtent
        let swapchainImageCount = min(self._maximumDrawableCount, Int(surfaceCapabilities.minImageCount))
        let presentMode = physicalDevice.getSurfacePresentModes(surface: surface)[0]
        let _device = device.getDevice()
        let swapchain = _device.createSwapchain(surface: surface,
                                                surfaceFormat: surfaceFormat,
                                                surfaceCapabilities: surfaceCapabilities,
                                                swapchainImageCount: swapchainImageCount,
                                                presentMode: presentMode)
        var renderFinishedSemaphores: [VulkanSemaphore] = []
        var imageAvailableSemaphores: [VulkanSemaphore] = []

        (0..<swapchainImageCount).forEach { _ in
            imageAvailableSemaphores.append(_device.createSemaphore())
            renderFinishedSemaphores.append(_device.createSemaphore())
        }

        self._reconfigureDevice = false
        self.device = device
        self.surface = surface
        self._pixelFormat = .bgra8Unorm
        self.extent = Size(width: Int(extent.width),
                           height: Int(extent.height),
                           depth: 1)
        self.swapchain = swapchain
        self.swapchainIndex = 0
        self.imageAvailableSemaphores = imageAvailableSemaphores
        self.renderFinishedSemaphores = renderFinishedSemaphores
    }

    internal func getDevice() -> VkMetalDevice {
        return self._device
    }

    internal func getSwapchain() -> VulkanSwapchain {
        return self.swapchain
    }

    public init(nativeWindowHandle: OpaquePointer) {
        self.nativeWindowHandle = nativeWindowHandle
    }

    public func nextDrawable() -> MetalProtocols.Drawable? {
        dispatchPrecondition(condition: .onQueue(.main))

        self.reconfigureDeviceIfNeeded()

        let swapchainIndex = self.swapchainIndex

        self.swapchainIndex += 1

        let imageAvailableSemaphore = self.imageAvailableSemaphores[swapchainIndex]
        let renderFinishedSemaphore = self.renderFinishedSemaphores[swapchainIndex]
        let imageIndex = swapchain.acquireNextImage(timeout: .max,
                                                    semaphore: imageAvailableSemaphore)
        let descriptor = TextureDescriptor.texture2DDescriptor(pixelFormat: self._pixelFormat,
                                                               width: self.extent.width,
                                                               height: self.extent.height,
                                                               mipmapped: false)
        let texture = VkMetalTexture(device: self._device,
                                     descriptor: descriptor,
                                     queueFamilies: [ self._device.getQueueFamilyIndex() ])
        let visual = Visual(layer: self,
                            imageIndex: imageIndex,
                            texture: texture,
                            availabilitySemaphore: imageAvailableSemaphore,
                            renderFinishedSemaphore: renderFinishedSemaphore)

        return visual
    }
}
