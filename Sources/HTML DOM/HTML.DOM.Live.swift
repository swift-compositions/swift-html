#if DOM
    public import WHATWG_DOM

    extension HTML.DOM {

        public final class Live {

            public let node: WHATWG.DOM.Node

            public let name: String

            public var data: String

            public var attributes: [(name: String, value: String)]

            public var listeners: [(event: WHATWG.DOM.Event, id: Int32)]

            public var children: [Live]

            public var key: HTML.DOM.Key?

            public init(node: WHATWG.DOM.Node, name: String, key: HTML.DOM.Key?) {
                self.node = node
                self.name = name
                self.data = ""
                self.attributes = []
                self.listeners = []
                self.children = []
                self.key = key
            }
        }
    }
#endif
