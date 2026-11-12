#if DOM
    public import Ordinal
    public import Renderer

    extension HTML.DOM {

        public struct Key: Hashable, Sendable {

            public let identity: Renderer.Document.Identity

            public let ordinal: Ordinal

            public init(_ identity: Renderer.Document.Identity, _ ordinal: Ordinal) {
                self.identity = identity
                self.ordinal = ordinal
            }
        }
    }
#endif
