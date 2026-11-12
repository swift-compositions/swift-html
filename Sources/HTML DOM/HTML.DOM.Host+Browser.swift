#if DOM
    #if arch(wasm32)
        extension HTML.DOM.Host {

            public static var browser: Self {
                Self(
                    flush: { bytes in
                        bytes.withUnsafeBytes { buffer in
                            unsafe _flush(buffer.baseAddress, Int32(buffer.count))
                        }
                    },
                    schedule: { _schedule() },
                    target: {
                        let count = _value(nil, 0)
                        var units = [UInt8](repeating: 0, count: Int(count))
                        units.withUnsafeMutableBytes { buffer in
                            _ = unsafe _value(buffer.baseAddress, count)
                        }
                        return HTML.DOM.Target(
                            value: String(decoding: units, as: UTF8.self),
                            checkedness: _checked() != 0 ? .checked : .unchecked
                        )
                    }
                )
            }
        }

        @_extern(wasm, module: "html_dom", name: "flush")
        private func _flush(_ pointer: UnsafeRawPointer?, _ count: Int32)

        @_extern(wasm, module: "html_dom", name: "schedule")
        private func _schedule()

        @_extern(wasm, module: "html_dom", name: "value")
        private func _value(_ pointer: UnsafeMutableRawPointer?, _ capacity: Int32) -> Int32

        @_extern(wasm, module: "html_dom", name: "checked")
        private func _checked() -> Int32

        @_expose(wasm, "html_dom_dispatch")
        public func _dispatch(_ listener: Int32) {
            unsafe HTML.DOM.Loop.dispatch(listener)
        }

        @_expose(wasm, "html_dom_tick")
        public func _tick() {
            unsafe HTML.DOM.Loop.tick()
        }
    #endif
#endif
