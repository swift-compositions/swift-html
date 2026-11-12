#if DOM
    public import Observer
    public import Ordinal
    public import Renderer
    import Sequence
    public import WHATWG_DOM

    extension HTML.DOM {

        public final class Mount {

            let host: HTML.DOM.Host

            let render: (inout Renderer.Document.Context) -> Void

            var batch: HTML.DOM.Batch

            let root: HTML.DOM.Live

            var styles: [HTML.Style.Rule: String]

            public private(set) var renders: Int

            var dirty: Bool

            init(
                selector: String,
                host: HTML.DOM.Host,
                render: @escaping (inout Renderer.Document.Context) -> Void
            ) {
                self.host = host
                self.render = render
                var batch = HTML.DOM.Batch()
                let node = batch.select(selector)
                batch.clear(node)
                self.batch = batch
                self.root = HTML.DOM.Live(node: node, name: "#root", key: nil)
                self.styles = [:]
                self.renders = 0
                self.dirty = true
            }
        }
    }

    extension HTML.DOM.Mount {

        public func update() {
            dirty = false
            renders += 1
            let sink = HTML.DOM.Sink(style: { self.register($0) })
            let index = unsafe HTML.DOM.Runtime.shared.index(of: self)
            Observer.Tracking.run(
                {
                    var context = sink.context
                    render(&context)
                },
                onChange: { unsafe HTML.DOM.Runtime.shared.invalidate(index) }
            )
            reconcile(root, sink.children)
            if !batch.isEmpty { host.flush(batch.drain()) }
        }

        func register(_ rule: HTML.Style.Rule) -> String {
            if let existing = styles[rule] { return existing }
            let name = "\(rule.propertyName)-\(styles.count)"
            styles[rule] = name
            var selector = ""
            if let prefix = rule.selector { selector += String(prefix) + " " }
            selector += "." + name
            if let pseudo = rule.pseudo { selector += String(pseudo) }
            var text = selector + "{" + rule.declaration + "}"
            if let atRule = rule.atRule { text = String(atRule) + "{" + text + "}" }
            batch.style(text)
            return name
        }
    }

    extension HTML.DOM.Mount {

        func create(_ virtual: HTML.DOM.Virtual) -> HTML.DOM.Live {
            if virtual.name == HTML.DOM.Virtual.text {
                let live = HTML.DOM.Live(node: batch.text(virtual.data), name: virtual.name, key: virtual.key)
                live.data = virtual.data
                return live
            }
            let live = HTML.DOM.Live(node: batch.element(virtual.name), name: virtual.name, key: virtual.key)
            patch(live, virtual)
            return live
        }

        func destroy(_ live: HTML.DOM.Live, detach: Bool) {
            for listener in live.listeners { unsafe HTML.DOM.Runtime.shared.remove(listener.id) }
            for child in live.children { destroy(child, detach: false) }
            if detach { batch.remove(live.node) } else { batch.release(live.node) }
        }

        func patch(_ live: HTML.DOM.Live, _ virtual: HTML.DOM.Virtual) {
            if live.name == HTML.DOM.Virtual.text {
                if live.data != virtual.data {
                    batch.data(virtual.data, on: live.node)
                    live.data = virtual.data
                }
                return
            }
            attributes(live, virtual.attributes)
            listeners(live, virtual.listeners)
            reconcile(live, virtual.children)
        }

        func attributes(_ live: HTML.DOM.Live, _ attributes: [(name: String, value: String)]) {
            let control = live.name == "input" || live.name == "textarea" || live.name == "select"
            for attribute in attributes {
                if control && attribute.name == "value" {
                    batch.value(attribute.value, on: live.node)
                } else if control && attribute.name == "checked" {
                    continue
                } else if live.attributes.first(where: { $0.name == attribute.name })?.value != attribute.value {
                    batch.attribute(attribute.name, attribute.value, on: live.node)
                }
            }
            if control, let kind = attributes.first(where: { $0.name == "type" })?.value, kind == "checkbox" || kind == "radio" {
                batch.checked(attributes.contains { $0.name == "checked" } ? .checked : .unchecked, on: live.node)
            }
            for old in live.attributes where !(control && (old.name == "value" || old.name == "checked")) {
                if !attributes.contains(where: { $0.name == old.name }) {
                    batch.attribute(old.name, nil, on: live.node)
                }
            }
            live.attributes = attributes
        }

        func listeners(_ live: HTML.DOM.Live, _ listeners: [Renderer.Document.Listener]) {
            let host = self.host
            var kept: [(event: WHATWG.DOM.Event, id: Int32)] = []
            var old = live.listeners
            for listener in listeners {
                let handle = listener.handle
                let handler: (Renderer.Document.Event) -> Void = { _ in
                    let target = host.target()
                    handle(Renderer.Document.Event(value: target.value, checked: target.checkedness == .checked))
                }
                if let index = old.firstIndex(where: { $0.event.type == listener.name }) {
                    let reused = old.remove(at: index)
                    unsafe HTML.DOM.Runtime.shared.replace(reused.id, with: handler)
                    kept.append(reused)
                } else {
                    let id = unsafe HTML.DOM.Runtime.shared.register(handler)
                    batch.listen(WHATWG.DOM.Event(listener.name), id, on: live.node)
                    kept.append((WHATWG.DOM.Event(listener.name), id))
                }
            }
            for stale in old {
                batch.ignore(stale.event, stale.id, on: live.node)
                unsafe HTML.DOM.Runtime.shared.remove(stale.id)
            }
            live.listeners = kept
        }

        func reconcile(_ parent: HTML.DOM.Live, _ virtuals: [HTML.DOM.Virtual]) {
            let old = parent.children
            let difference = Sequence.Difference.Keyed(
                old: old.map { $0.key },
                new: virtuals.map { $0.key }
            ) { from, to in
                old[Int(bitPattern: from)].name == virtuals[Int(bitPattern: to)].name
            }
            for index in difference.removed {
                destroy(old[Int(bitPattern: index)], detach: true)
            }
            var children = [HTML.DOM.Live?](repeating: nil, count: virtuals.count)
            var anchor: HTML.DOM.Node? = nil
            for index in virtuals.indices.reversed() {
                let live: HTML.DOM.Live
                switch difference.placements[index] {
                case .kept(let source):
                    live = old[Int(bitPattern: source)]
                    patch(live, virtuals[index])

                case .moved(let source):
                    live = old[Int(bitPattern: source)]
                    patch(live, virtuals[index])
                    batch.insert(live.node, into: parent.node, before: anchor)

                case .inserted:
                    live = create(virtuals[index])
                    batch.insert(live.node, into: parent.node, before: anchor)
                }
                children[index] = live
                anchor = live.node
            }
            parent.children = children.compactMap { $0 }
        }
    }
#endif
