import Foundation
import MetalProtocols

internal final class VkMetalBuffer: VkMetalResource,
                                    Buffer {
    private var _length: Int
    private var _contents: UnsafeMutableRawPointer

    public override var allocatedSize: Int {
        return self.length
    }

    public override var description: String {
        return super.description + " length: \(self.length) contents: \(self.contents())"
    }

    public var length: Int {
        return self._length
    }

    internal init(device: VkMetalDevice,
                  length: Int) {
        self._length = length
        self._contents = malloc(length)
        super.init(device: device)
    }

    deinit {
        free(self._contents)
    }

    public func contents() -> UnsafeMutableRawPointer {
        self._contents
    }
}
