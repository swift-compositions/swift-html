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
                    },
                    elapsed: { .microseconds(Int64(_elapsed() * 1000)) },
                    timer: { delay, token in
                        let (seconds, attoseconds) = delay.components
                        let milliseconds = seconds * 1000 + (attoseconds + 999_999_999_999_999) / 1_000_000_000_000_000
                        _timer(token, Int32(clamping: max(milliseconds, 0)))
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

        @_extern(wasm, module: "html_dom", name: "elapsed")
        private func _elapsed() -> Double

        @_extern(wasm, module: "html_dom", name: "timer")
        private func _timer(_ token: Int32, _ milliseconds: Int32)

        @_expose(wasm, "html_dom_dispatch")
        public func _dispatch(_ listener: Int32) {
            HTML.DOM.Loop.enter { unsafe HTML.DOM.Loop.dispatch(listener) }
        }

        @_expose(wasm, "html_dom_tick")
        public func _tick() {
            HTML.DOM.Loop.enter { unsafe HTML.DOM.Loop.tick() }
        }

        @_expose(wasm, "html_dom_timer")
        public func _fire(_ token: Int32) {
            HTML.DOM.Loop.enter { unsafe HTML.DOM.Runtime.shared.fire(token) }
        }
    #endif
#endif
