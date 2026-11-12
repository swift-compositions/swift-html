#if DOM
    public import HTML_DOM
    public import WHATWG_DOM

    extension HTML.DOM.Memory {

        public final class Element {

            public var name: String

            public var data: String

            public var attributes: [(name: String, value: String)]

            public var value: String

            public var checkedness: WHATWG.DOM.Checkedness

            public var children: [HTML.DOM.Memory.Element]

            public weak var parent: HTML.DOM.Memory.Element?

            public var listeners: [(event: String, listener: Int32)]

            public init(name: String, data: String = "") {
                self.name = name
                self.data = data
                self.attributes = []
                self.value = ""
                self.checkedness = .unchecked
                self.children = []
                self.listeners = []
            }
        }
    }

    extension HTML.DOM.Memory.Element {

        public var html: String {
            if name == "#text" { return data }
            var text = "<" + name
            for attribute in attributes {
                text += " \(attribute.name)=\"\(attribute.value)\""
            }
            if checkedness == .checked { text += " :checked" }
            if !value.isEmpty { text += " :value=\"\(value)\"" }
            return text + ">" + children.map(\.html).joined() + "</" + name + ">"
        }

        public func first(_ name: String) -> HTML.DOM.Memory.Element? {
            for child in children {
                if child.name == name { return child }
                if let found = child.first(name) { return found }
            }
            return nil
        }

        func detach() {
            parent?.children.removeAll { $0 === self }
            parent = nil
        }

        func insert(_ child: HTML.DOM.Memory.Element, before anchor: HTML.DOM.Memory.Element?) {
            child.detach()
            if let anchor, let index = children.firstIndex(where: { $0 === anchor }) {
                children.insert(child, at: index)
            } else {
                children.append(child)
            }
            child.parent = self
        }

        func set(_ name: String, _ value: String) {
            if let index = attributes.firstIndex(where: { $0.name == name }) {
                attributes[index].value = value
            } else {
                attributes.append((name, value))
            }
        }
    }
#endif
