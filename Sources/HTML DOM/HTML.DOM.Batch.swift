#if DOM
    internal import Binary
    public import Byte
    public import WHATWG_DOM

    extension HTML.DOM {

        public struct Batch: Sendable {

            public private(set) var bytes: [Byte]

            private var next: Int32

            private var free: [Int32]

            public init() {
                self.bytes = []
                self.next = 1
                self.free = []
            }
        }
    }

    extension HTML.DOM.Batch {

        public var isEmpty: Bool { bytes.isEmpty }

        public mutating func drain() -> [Byte] {
            defer { bytes.removeAll(keepingCapacity: true) }
            return bytes
        }

        private mutating func allocate() -> HTML.DOM.Node {
            if let id = free.popLast() { return HTML.DOM.Node(id) }
            defer { next += 1 }
            return HTML.DOM.Node(next)
        }

        private mutating func write(_ operation: HTML.DOM.Operation) {
            bytes.append(Byte(operation))
        }

        private mutating func write(_ value: Int32) {
            value.bytes(into: &bytes, endianness: .little)
        }

        private mutating func write(_ node: HTML.DOM.Node) {
            write(node.id)
        }

        private mutating func write(_ string: String) {
            write(Int32(string.utf8.count))
            for unit in string.utf8 {
                bytes.append(Byte(bitPattern: unit))
            }
        }
    }

    extension HTML.DOM.Batch {

        public mutating func element(_ name: String) -> HTML.DOM.Node {
            let node = allocate()
            write(.element)
            write(node)
            write(name)
            return node
        }

        public mutating func text(_ data: String) -> HTML.DOM.Node {
            let node = allocate()
            write(.text)
            write(node)
            write(data)
            return node
        }

        public mutating func select(_ selector: String) -> HTML.DOM.Node {
            let node = allocate()
            write(.select)
            write(node)
            write(selector)
            return node
        }

        public mutating func insert(_ child: HTML.DOM.Node, into parent: HTML.DOM.Node, before: HTML.DOM.Node?) {
            write(.insert)
            write(parent)
            write(child)
            write(before?.id ?? 0)
        }

        public mutating func remove(_ node: HTML.DOM.Node) {
            write(.remove)
            write(node)
            free.append(node.id)
        }

        public mutating func release(_ node: HTML.DOM.Node) {
            write(.release)
            write(node)
            free.append(node.id)
        }

        public mutating func attribute(_ name: String, _ value: String?, on node: HTML.DOM.Node) {
            if let value {
                write(.attribute)
                write(node)
                write(name)
                write(value)
            } else {
                write(.unset)
                write(node)
                write(name)
            }
        }

        public mutating func value(_ value: String, on node: HTML.DOM.Node) {
            write(.value)
            write(node)
            write(value)
        }

        public mutating func checked(_ checkedness: WHATWG.DOM.Checkedness, on node: HTML.DOM.Node) {
            write(.checked)
            write(node)
            bytes.append(Byte(bitPattern: checkedness == .checked ? 1 : 0))
        }

        public mutating func data(_ data: String, on node: HTML.DOM.Node) {
            write(.data)
            write(node)
            write(data)
        }

        public mutating func listen(_ event: WHATWG.DOM.Event, _ listener: Int32, on node: HTML.DOM.Node) {
            write(.listen)
            write(node)
            write(event.type)
            write(listener)
        }

        public mutating func ignore(_ event: WHATWG.DOM.Event, _ listener: Int32, on node: HTML.DOM.Node) {
            write(.ignore)
            write(node)
            write(event.type)
            write(listener)
        }

        public mutating func clear(_ node: HTML.DOM.Node) {
            write(.clear)
            write(node)
        }

        public mutating func style(_ rule: String) {
            write(.style)
            write(rule)
        }
    }
#endif
