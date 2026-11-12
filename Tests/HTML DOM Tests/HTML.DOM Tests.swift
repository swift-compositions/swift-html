import HTML
import HTML_DOM
import Optic
import Testing
import WHATWG_DOM_Test_Support

@Observable
final class Model {
    var count = 0
    var name = "Ada"
    var done = false
    var rows: [Int] = [1, 2, 3]
}

struct Counter: HTML.View {
    let model: Model

    var body: some HTML.View {
        div {
            p { "Count: \(model.count)" }
            button { "+" }
                .on(.click) { model.count += 1 }
        }
    }
}

struct Rows: HTML.View {
    let model: Model

    var body: some HTML.View {
        ul {
            HTML.ForEach(model.rows, id: { $0 }) { row in
                li { "\(row)" }
            }
        }
    }
}

struct Form: HTML.View {
    let model: Model

    var body: some HTML.View {
        div {
            input.text()
                .value(Optic<Void, Void, String, String>.Lens(get: { _ in model.name }, set: { _, new in model.name = new }))
            input.checkbox
                .checked(Optic<Void, Void, Bool, Bool>.Lens(get: { _ in model.done }, set: { _, new in model.done = new }))
            p { "\(model.name) \(model.done ? "done" : "open")" }
        }
    }
}

enum `HTML.DOM Tests` {}

extension `HTML.DOM Tests` {
    @Suite(.serialized)
    struct `A mounted view renders once and patches only what changed` {
        init() {
            unsafe HTML.DOM.Runtime.shared.unmount()
        }
    }
}

extension `HTML.DOM Tests`.`A mounted view renders once and patches only what changed` {

    @Test
    func `mount renders the view in one flush`() {
        let memory = WHATWG.DOM.Memory()
        let model = Model()
        HTML.DOM.mount(in: "#app", host: memory.host) { Counter(model: model) }
        #expect(memory.html == "<div><p>Count: 0</p><button>+</button></div>")
        #expect(memory.flushes == 1)
    }

    @Test
    func `a click changes state and only the changed text is patched`() {
        let memory = WHATWG.DOM.Memory()
        let model = Model()
        HTML.DOM.mount(in: "#app", host: memory.host) { Counter(model: model) }
        let before = memory.operations
        memory.fire(.click, on: memory.first("button"))
        #expect(model.count == 1)
        #expect(memory.scheduled == 1)
        unsafe WHATWG.DOM.Loop.tick()
        #expect(memory.html == "<div><p>Count: 1</p><button>+</button></div>")
        #expect(memory.operations - before == 1)
    }

    @Test
    func `several changes before a tick render once`() {
        let memory = WHATWG.DOM.Memory()
        let model = Model()
        let mount = HTML.DOM.mount(in: "#app", host: memory.host) { Counter(model: model) }
        model.count = 5
        model.count = 6
        #expect(memory.scheduled == 1)
        unsafe WHATWG.DOM.Loop.tick()
        #expect(mount.renders == 2)
        #expect(memory.html == "<div><p>Count: 6</p><button>+</button></div>")
    }

    @Test
    func `a tick without a change does nothing`() {
        let memory = WHATWG.DOM.Memory()
        let model = Model()
        let mount = HTML.DOM.mount(in: "#app", host: memory.host) { Counter(model: model) }
        unsafe WHATWG.DOM.Loop.tick()
        #expect(mount.renders == 1)
        #expect(memory.flushes == 1)
    }

    @Test
    func `state the view did not read does not re-render`() {
        let memory = WHATWG.DOM.Memory()
        let model = Model()
        HTML.DOM.mount(in: "#app", host: memory.host) { Counter(model: model) }
        model.name = "Grace"
        #expect(memory.scheduled == 0)
    }

    @Test
    func `keyed rows keep their elements when reordered`() {
        let memory = WHATWG.DOM.Memory()
        let model = Model()
        HTML.DOM.mount(in: "#app", host: memory.host) { Rows(model: model) }
        let before = memory.first("ul").children
        let operations = memory.operations
        model.rows = [3, 1, 2]
        unsafe WHATWG.DOM.Loop.tick()
        let after = memory.first("ul").children
        #expect(memory.html == "<ul><li>3</li><li>1</li><li>2</li></ul>")
        #expect(after[0] === before[2])
        #expect(after[1] === before[0])
        #expect(after[2] === before[1])
        #expect(memory.operations - operations == 1)
    }

    @Test
    func `keyed rows are added and removed in place`() {
        let memory = WHATWG.DOM.Memory()
        let model = Model()
        HTML.DOM.mount(in: "#app", host: memory.host) { Rows(model: model) }
        let three = memory.first("ul").children[2]
        model.rows = [3, 4]
        unsafe WHATWG.DOM.Loop.tick()
        #expect(memory.html == "<ul><li>3</li><li>4</li></ul>")
        #expect(memory.first("ul").children[0] === three)
    }

    @Test
    func `value and checked bindings write back and re-render`() {
        let memory = WHATWG.DOM.Memory()
        let model = Model()
        HTML.DOM.mount(in: "#app", host: memory.host) { Form(model: model) }
        let inputs = memory.first("div").children
        memory.fire(.input, on: inputs[0], target: WHATWG.DOM.Target(value: "Grace"))
        memory.fire(.change, on: inputs[1], target: WHATWG.DOM.Target(checkedness: .checked))
        unsafe WHATWG.DOM.Loop.tick()
        #expect(model.name == "Grace")
        #expect(model.done)
        #expect(memory.first("p").children.first?.data == "Grace done")
        #expect(inputs[0].value == "Grace")
        #expect(inputs[1].checkedness == .checked)
    }

    @Test
    func `listeners are reused across renders`() {
        let memory = WHATWG.DOM.Memory()
        let model = Model()
        HTML.DOM.mount(in: "#app", host: memory.host) { Counter(model: model) }
        let button = memory.first("button")
        for _ in 0..<3 {
            memory.fire(.click, on: button)
            unsafe WHATWG.DOM.Loop.tick()
        }
        #expect(model.count == 3)
        #expect(unsafe HTML.DOM.Runtime.shared.listeners == 1)
        #expect(button.listeners.count == 1)
    }

    @Test
    func `the same view renders to a string on the server`() throws {
        let model = Model()
        #expect(try String(Counter(model: model)).contains("<button>+</button>"))
    }
}
