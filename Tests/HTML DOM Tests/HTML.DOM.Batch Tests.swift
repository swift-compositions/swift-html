#if DOM
    import Byte
    import HTML_DOM
    import HTML_DOM_Test_Support
    import Testing

    extension `HTML.DOM Tests` {
        @Suite
        struct `A batch records DOM changes as one command buffer` {}
    }

    extension `HTML.DOM Tests`.`A batch records DOM changes as one command buffer` {

        @Test
        func `a batch builds a tree in one flush`() {
            let memory = HTML.DOM.Memory()
            var batch = HTML.DOM.Batch()
            let root = batch.select("#app")
            let button = batch.element("button")
            batch.attribute("id", "go", on: button)
            let label = batch.text("Go")
            batch.insert(label, into: button, before: nil)
            batch.insert(button, into: root, before: nil)
            memory.apply(batch.drain())
            #expect(memory.html == #"<button id="go">Go</button>"#)
            #expect(memory.flushes == 1)
            #expect(batch.isEmpty)
        }

        @Test
        func `insert before an anchor puts the child in front of it`() {
            let memory = HTML.DOM.Memory()
            var batch = HTML.DOM.Batch()
            let root = batch.select("#app")
            let a = batch.element("a")
            let b = batch.element("b")
            batch.insert(b, into: root, before: nil)
            batch.insert(a, into: root, before: b)
            memory.apply(batch.drain())
            #expect(memory.html == "<a></a><b></b>")
        }

        @Test
        func `a removed node's id is reused`() {
            var batch = HTML.DOM.Batch()
            let first = batch.element("p")
            batch.remove(first)
            let second = batch.element("p")
            #expect(first == second)
        }

        @Test
        func `attributes, properties, text data and unset round-trip`() {
            let memory = HTML.DOM.Memory()
            var batch = HTML.DOM.Batch()
            let root = batch.select("#app")
            let input = batch.element("input")
            batch.attribute("type", "checkbox", on: input)
            batch.attribute("title", "x", on: input)
            batch.attribute("title", nil, on: input)
            batch.checked(.checked, on: input)
            batch.value("é", on: input)
            let text = batch.text("old")
            batch.data("new", on: text)
            batch.insert(input, into: root, before: nil)
            batch.insert(text, into: root, before: nil)
            memory.apply(batch.drain())
            #expect(memory.html == #"<input type="checkbox" :checked :value="é"></input>new"#)
        }

        @Test
        func `a listener receives its dispatch`() {
            let memory = HTML.DOM.Memory()
            var batch = HTML.DOM.Batch()
            let root = batch.select("#app")
            let button = batch.element("button")
            batch.listen(.click, 7, on: button)
            batch.insert(button, into: root, before: nil)
            memory.apply(batch.drain())
            var received: [Int32] = []
            unsafe HTML.DOM.Loop.dispatch = { received.append($0) }
            memory.fire(.click, on: memory.first("button"))
            #expect(received == [7])
            batch.ignore(.click, 7, on: button)
            memory.apply(batch.drain())
            memory.fire(.click, on: memory.first("button"))
            #expect(received == [7])
        }

        @Test
        func `the script handles every operation`() {
            for operation in HTML.DOM.Operation.allCases {
                #expect(HTML.DOM.Script.source.contains("case \(UInt8(bitPattern: Byte(operation))):"))
            }
        }

        @Test
        func `the script gives a command module an empty argument list`() {
            #expect(HTML.DOM.Script.source.contains("args_sizes_get(count, size)"))
            #expect(HTML.DOM.Script.source.contains("args_get()"))
        }
    }
#endif
