#if DOM
    import Binary
    public import Byte
    public import HTML_DOM

    extension HTML.DOM.Memory {

        public struct Reader {

            let bytes: [Byte]

            var at: Int

            public init(_ bytes: [Byte]) {
                self.bytes = bytes
                self.at = 0
            }
        }
    }

    extension HTML.DOM.Memory.Reader {

        public mutating func byte() -> Byte {
            defer { at += 1 }
            return bytes[at]
        }

        public mutating func operation() -> HTML.DOM.Operation? {
            guard at < bytes.count else { return nil }
            return HTML.DOM.Operation(byte())
        }

        public mutating func int() -> Int32 {
            defer { at += 4 }
            return Int32(bytes: bytes[at..<(at + 4)], endianness: .little) ?? 0
        }

        public mutating func string() -> String {
            let count = Int(int())
            defer { at += count }
            return String(decoding: bytes[at..<(at + count)].map { UInt8(bitPattern: $0) }, as: UTF8.self)
        }
    }
#endif
