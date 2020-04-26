import swiftVulkan
import Dispatch
import Foundation
import MetalProtocols

internal final class VkMetalSharedEvent: VkMetalObject,
                                         Hashable,
                                         SharedEvent {
    private let executionQueue = DispatchQueue(label: "VkMetalSharedEventListener.executionQueue")
    private var event: VulkanEvent? = nil
    private var value: UInt64
    private var listeners: [VkMetalSharedEventListener] = []

    public var signaledValue: UInt64 {
        get { 0 }
        set { }
    }

    public static func == (lhs: VkMetalSharedEvent,
                           rhs: VkMetalSharedEvent) -> Bool {
        return lhs === rhs
    }

    internal func getEvent() -> VulkanEvent? {
        return self.executionQueue.sync { self.event }
    }

    internal func issueListeners() {
        self.executionQueue.async {
            self.listeners.forEach { $0.issue(device: self._device.device,
                                              sharedEvent: self) }
            self.listeners.removeAll()
        }
    }

    public override init(device: VkMetalDevice) {
        self.value = 0
        super.init(device: device)
    }

    public func hash(into hasher: inout Hasher) {
    }

    public func makeSharedEventHandle() -> SharedEventHandle {
        return SharedEventHandle()
    }

    public func notify(_ listener: SharedEventListener,
                       atValue value: UInt64,
                       block: @escaping SharedEvent.NotificationBlock) {
        self.executionQueue.sync {
            let _listener = listener as! VkMetalSharedEventListener
            let _device = self._device.device
            let event = _device.createEvent()

            _listener.addEvent(event: event,
                               value: value,
                               block: block)
            self.listeners.append(_listener)
            self.event = event
        }
    }
}

public final class VkMetalSharedEventListener: SharedEventListener {
    private let executionQueue = DispatchQueue(label: "VkMetalSharedEventListener.executionQueue")
    private var events: [(value: UInt64,
                          event: VulkanEvent,
                          notification: SharedEvent.NotificationBlock)] = []

    private func eventHandler(device: VulkanDevice,
                              sharedEvent: SharedEvent) {
        self.executionQueue.async {
            let events = self.events
            var handledEvents = 0

            while handledEvents != events.count {
                for i in 0..<events.count {
                    let event = events[i].event
                    let notification = events[i].notification
                    let value = events[i].value

                    guard event.getEventStatus() else {
                        continue
                    }

                    notification(sharedEvent,
                                 value)
                    handledEvents += 1
                }
            }
            self.events.forEach { $0 }
            self.events.removeAll()
        }
    }

    internal func addEvent(event: VulkanEvent,
                           value: UInt64,
                           block: @escaping SharedEvent.NotificationBlock) {
        self.executionQueue.sync {
            self.events.append((value: value,
                                event: event,
                                notification: block))
        }
    }

    internal func issue(device: VulkanDevice,
                        sharedEvent: SharedEvent) {
        self.eventHandler(device: device,
                          sharedEvent: sharedEvent)
    }
}
