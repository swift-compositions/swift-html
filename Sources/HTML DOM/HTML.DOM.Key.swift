public import Renderer

extension HTML.DOM {

    public struct Key: Hashable, Sendable {

        public let identity: Renderer.Document.Identity

        public let ordinal: Int

        public init(_ identity: Renderer.Document.Identity, _ ordinal: Int) {
            self.identity = identity
            self.ordinal = ordinal
        }
    }
}
