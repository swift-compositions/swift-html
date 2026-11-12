#if DOM
    public import Byte

    extension HTML.DOM {

        public enum Operation: Sendable, CaseIterable {
            case element
            case text
            case select
            case insert
            case remove
            case release
            case attribute
            case unset
            case value
            case checked
            case data
            case listen
            case ignore
            case clear
            case style
        }
    }

    extension HTML.DOM.Operation {

        public init?(_ byte: Byte) {
            guard let operation = Self.allCases.first(where: { Byte($0) == byte }) else { return nil }
            self = operation
        }
    }

    extension Byte {

        public init(_ operation: HTML.DOM.Operation) {
            switch operation {
            case .element: self.init(bitPattern: 1)
            case .text: self.init(bitPattern: 2)
            case .select: self.init(bitPattern: 3)
            case .insert: self.init(bitPattern: 4)
            case .remove: self.init(bitPattern: 5)
            case .release: self.init(bitPattern: 6)
            case .attribute: self.init(bitPattern: 7)
            case .unset: self.init(bitPattern: 8)
            case .value: self.init(bitPattern: 9)
            case .checked: self.init(bitPattern: 10)
            case .data: self.init(bitPattern: 11)
            case .listen: self.init(bitPattern: 12)
            case .ignore: self.init(bitPattern: 13)
            case .clear: self.init(bitPattern: 14)
            case .style: self.init(bitPattern: 15)
            }
        }
    }
#endif
