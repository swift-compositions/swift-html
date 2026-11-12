#if DOM
    public import Renderer
    public import WHATWG_DOM

    extension HTML.DOM {

        public final class Runtime {

            var mounts: [HTML.DOM.Mount]

            var handlers: [Int32: (Renderer.Document.Event) -> Void]

            var next: Int32

            var free: [Int32]

            var pending: Bool

            init() {
                self.mounts = []
                self.handlers = [:]
                self.next = 1
                self.free = []
                self.pending = false
            }
        }
    }

    extension HTML.DOM.Runtime {

        // WHY: a WebAssembly module in a page runs on the page's one thread; the page's events and microtasks are its only callers, one at a time.
        nonisolated(unsafe) public static let shared = HTML.DOM.Runtime()
    }

    extension HTML.DOM.Runtime {

        public var listeners: Int { handlers.count }

        func install(_ mount: HTML.DOM.Mount) {
            mounts.append(mount)
            unsafe WHATWG.DOM.Loop.dispatch = { id in
                unsafe HTML.DOM.Runtime.shared.dispatch(id)
            }
            unsafe WHATWG.DOM.Loop.tick = {
                unsafe HTML.DOM.Runtime.shared.tick()
            }
        }

        func index(of mount: HTML.DOM.Mount) -> Int {
            mounts.firstIndex { $0 === mount } ?? -1
        }

        func invalidate(_ index: Int) {
            guard mounts.indices.contains(index) else { return }
            mounts[index].dirty = true
            guard !pending else { return }
            pending = true
            mounts[index].host.schedule()
        }

        public func tick() {
            pending = false
            for mount in mounts where mount.dirty {
                mount.update()
            }
        }

        public func unmount() {
            mounts.removeAll()
            handlers.removeAll()
            free.removeAll()
            next = 1
            pending = false
        }

        func register(_ handler: @escaping (Renderer.Document.Event) -> Void) -> Int32 {
            let id: Int32
            if let reused = free.popLast() {
                id = reused
            } else {
                id = next
                next += 1
            }
            handlers[id] = handler
            return id
        }

        func replace(_ id: Int32, with handler: @escaping (Renderer.Document.Event) -> Void) {
            handlers[id] = handler
        }

        func remove(_ id: Int32) {
            handlers[id] = nil
            free.append(id)
        }

        func dispatch(_ id: Int32) {
            handlers[id]?(Renderer.Document.Event())
        }
    }
#endif
