#if DOM
    public import Byte

    extension HTML.DOM {

        public struct Host {

            public var flush: ([Byte]) -> Void

            public var schedule: () -> Void

            public var target: () -> HTML.DOM.Target

            public init(
                flush: @escaping ([Byte]) -> Void,
                schedule: @escaping () -> Void,
                target: @escaping () -> HTML.DOM.Target
            ) {
                self.flush = flush
                self.schedule = schedule
                self.target = target
            }
        }
    }
#endif
