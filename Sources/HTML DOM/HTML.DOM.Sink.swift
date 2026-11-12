public import Renderer

extension HTML.DOM {

    public final class Sink {

        var open: [HTML.DOM.Virtual]

        var pending: HTML.DOM.Sink.Pending

        var saved: [HTML.DOM.Sink.Pending]

        var scopes: [HTML.DOM.Sink.Scope]

        let style: (HTML.Style.Rule) -> String

        public init(style: @escaping (HTML.Style.Rule) -> String) {
            self.open = [HTML.DOM.Virtual(name: "#root")]
            self.pending = HTML.DOM.Sink.Pending()
            self.saved = []
            self.scopes = []
            self.style = style
        }
    }
}

extension HTML.DOM.Sink {

    public var children: [HTML.DOM.Virtual] { open[0].children }

    func key() -> HTML.DOM.Key? {
        guard let last = scopes.indices.last, scopes[last].depth == open.count else { return nil }
        defer { scopes[last].ordinal += 1 }
        return HTML.DOM.Key(scopes[last].identity, scopes[last].ordinal)
    }

    func append(_ virtual: HTML.DOM.Virtual) {
        open[open.count - 1].children.append(virtual)
    }

    func text(_ data: String) {
        append(HTML.DOM.Virtual(name: HTML.DOM.Virtual.text, data: data, key: key()))
    }

    func push(_ name: String, attributes extra: [(name: String, value: String)] = []) {
        var virtual = HTML.DOM.Virtual(name: name, key: key())
        virtual.attributes = extra + pending.attributes
        virtual.listeners = pending.listeners
        open.append(virtual)
        saved.append(pending)
        pending = HTML.DOM.Sink.Pending()
    }

    func pop() {
        guard open.count > 1 else { return }
        let virtual = open.removeLast()
        pending = saved.popLast() ?? HTML.DOM.Sink.Pending()
        append(virtual)
    }

    func save() {
        saved.append(pending)
    }

    func restore() {
        pending = saved.popLast() ?? HTML.DOM.Sink.Pending()
    }

    func set(_ name: String, _ value: String?) {
        guard let value else { return }
        if let index = pending.attributes.firstIndex(where: { $0.name == name }) {
            pending.attributes[index].value = value
        } else {
            pending.attributes.append((name, value))
        }
    }

    func add(_ name: String) {
        if let index = pending.attributes.firstIndex(where: { $0.name == "class" }) {
            pending.attributes[index].value += " " + name
        } else {
            pending.attributes.append(("class", name))
        }
    }

    func single(_ name: String, attributes: [(name: String, value: String)] = []) {
        push(name, attributes: attributes)
        pop()
    }

    static func name(_ role: Renderer.Document.Semantic.Block?) -> String {
        switch role {
        case .heading(let level): "h\(level)"
        case .paragraph: "p"
        case .blockquote: "blockquote"
        case .section: "section"
        case .pre: "pre"
        case .table: "table"
        case .row: "tr"
        case .cell(header: true): "th"
        case .cell(header: false): "td"
        case nil: "div"
        }
    }

    static func name(_ role: Renderer.Document.Semantic.Inline?) -> String {
        switch role {
        case .emphasis: "em"
        case .strong: "strong"
        case .code: "code"
        case nil: "span"
        }
    }
}

extension HTML.DOM.Sink {

    public var context: Renderer.Document.Context {
        Renderer.Document.Context(
            text: { self.text($0) },
            break: Renderer.Document.Break(
                line: { self.single("br") },
                thematic: { self.single("hr") },
                page: {}
            ),
            image: { self.single("img", attributes: [("src", $0), ("alt", $1)]) },
            push: Renderer.Document.Push(
                block: { role, _ in self.push(Self.name(role)) },
                inline: { role, _ in self.push(Self.name(role)) },
                list: { kind, _ in self.push(kind == .ordered ? "ol" : "ul") },
                item: { self.push("li") },
                link: { self.push("a", attributes: [("href", $0)]) },
                attributes: { self.save() },
                element: { name, _, _, _ in self.push(name) },
                style: { self.save() },
                identity: { self.scopes.append(HTML.DOM.Sink.Scope(identity: $0, depth: self.open.count, ordinal: 0)) }
            ),
            pop: Renderer.Document.Pop(
                block: { self.pop() },
                inline: { self.pop() },
                list: { self.pop() },
                item: { self.pop() },
                link: { self.pop() },
                attributes: { self.restore() },
                element: { _ in self.pop() },
                style: { self.restore() },
                identity: { _ = self.scopes.popLast() }
            ),
            setAttribute: { self.set($0, $1) },
            addClass: { self.add($0) },
            registerStyle: { declaration, atRule, selector, pseudo in
                self.style(
                    HTML.Style.Rule(
                        declaration: declaration,
                        atRule: atRule.map { HTML.AtRule(rawValue: $0) },
                        selector: selector.map { HTML.Selector(rawValue: $0) },
                        pseudo: pseudo.map { HTML.Pseudo(rawValue: $0) }
                    )
                )
            },
            listen: { self.pending.listeners.append($0) }
        )
    }
}
