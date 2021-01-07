

import Foundation

final class Queue {
    public static func main(_ after: DispatchTimeInterval = .milliseconds(0),
                              _ service: DispatchQoS = .userInteractive ,
                              _ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after,
                                      qos: service,
                                      execute: closure)
    }

    public static func onGlobal(_ after: DispatchTimeInterval = .milliseconds(0),
                                _ service: DispatchQoS = .utility ,
                                _ closure: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated)
            .asyncAfter(deadline: .now() + after,
                        qos: service,
                        execute: closure)
    }
}
