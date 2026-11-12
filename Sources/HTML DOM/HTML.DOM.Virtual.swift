public import Renderer

extension HTML.DOM {

    public struct Virtual {

        public var name: String

        public var data: String

        public var attributes: [(name: String, value: String)]

        public var listeners: [Renderer.Document.Listener]

        public var children: [Virtual]

        public var key: HTML.DOM.Key?

        public init(
            name: String,
            data: String = "",
            attributes: [(name: String, value: String)] = [],
            listeners: [Renderer.Document.Listener] = [],
            children: [Virtual] = [],
            key: HTML.DOM.Key? = nil
        ) {
            self.name = name
            self.data = data
            self.attributes = attributes
            self.listeners = listeners
            self.children = children
            self.key = key
        }
    }
}

extension HTML.DOM.Virtual {
    public static let text = "#text"
}
