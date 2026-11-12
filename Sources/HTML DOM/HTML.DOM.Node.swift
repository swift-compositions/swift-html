#if DOM
    extension HTML.DOM {

        public struct Node: Hashable, Sendable {

            public let id: Int32

            public init(_ id: Int32) {
                self.id = id
            }
        }
    }
#endif
