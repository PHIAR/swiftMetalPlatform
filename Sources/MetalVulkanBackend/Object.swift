import MetalProtocols

public protocol VkMetalObjectInterface {
    var label: String? { get nonmutating set }
}

public class VkMetalObject: CustomStringConvertible,
                            VkMetalObjectInterface {
    internal let _device: VkMetalDevice
    internal var debugLabel: String? = nil

    public var description: String {
        return "\(type(of: self)): device: \(self.device) label: \"" +
               (self.debugLabel ?? "(none)") + "\""
    }

    public var device: Device {
        return self._device
    }

    public var label: String? {
        get {
            return self.debugLabel
        }

        set {
            self.debugLabel = newValue
        }
    }

    internal init(device: VkMetalDevice) {
        self._device = device
    }
}
