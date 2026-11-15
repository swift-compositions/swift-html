#if DOM
    public import Byte

    extension HTML.DOM {

        public struct Host {

            public var flush: ([Byte]) -> Void

            public var schedule: () -> Void

            public var target: () -> HTML.DOM.Target

            public var elapsed: () -> Duration

            public var timer: (Duration, Int32) -> Void

            public init(
                flush: @escaping ([Byte]) -> Void,
                schedule: @escaping () -> Void,
                target: @escaping () -> HTML.DOM.Target,
                elapsed: @escaping () -> Duration = { .zero },
                timer: @escaping (Duration, Int32) -> Void = { _, _ in }
            ) {
                self.flush = flush
                self.schedule = schedule
                self.target = target
                self.elapsed = elapsed
                self.timer = timer
            }
        }
    }
#endif
