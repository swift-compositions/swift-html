#if DOM
    import HTML
    import HTML_DOM
    import Testing
    import HTML_DOM_Test_Support

    extension `HTML.DOM Tests` {
        @Suite(.serialized)
        struct `A timer asks the host once and runs its body when it fires` {
            init() {
                unsafe HTML.DOM.Runtime.shared.unmount()
            }
        }
    }

    extension `HTML.DOM Tests`.`A timer asks the host once and runs its body when it fires` {

        @Test
        func `a timer runs after its delay and not before`() {
            let memory = HTML.DOM.Memory()
            let model = Model()
            HTML.DOM.mount(in: "#app", host: memory.host) { Counter(model: model) }
            unsafe HTML.DOM.Runtime.shared.after(.seconds(1)) { model.count += 1 }
            #expect(memory.timers.count == 1)
            #expect(memory.timers.first?.due == .seconds(1))
            memory.advance(by: .milliseconds(999))
            #expect(model.count == 0)
            memory.advance(by: .milliseconds(1))
            #expect(model.count == 1)
            #expect(unsafe HTML.DOM.Runtime.shared.scheduled == 0)
            unsafe HTML.DOM.Loop.tick()
            #expect(memory.html == "<div><p>Count: 1</p><button>+</button></div>")
        }

        @Test
        func `timers fire in the order they are due`() {
            let memory = HTML.DOM.Memory()
            let model = Model()
            HTML.DOM.mount(in: "#app", host: memory.host) { Counter(model: model) }
            var order: [Int] = []
            unsafe HTML.DOM.Runtime.shared.after(.milliseconds(300)) { order.append(3) }
            unsafe HTML.DOM.Runtime.shared.after(.milliseconds(100)) { order.append(1) }
            unsafe HTML.DOM.Runtime.shared.after(.milliseconds(200)) { order.append(2) }
            memory.advance(by: .seconds(1))
            #expect(order == [1, 2, 3])
            #expect(unsafe HTML.DOM.Runtime.shared.elapsed == .seconds(1))
        }

        @Test
        func `a token fires its body once`() {
            let memory = HTML.DOM.Memory()
            HTML.DOM.mount(in: "#app", host: memory.host) { Counter(model: Model()) }
            var runs = 0
            unsafe HTML.DOM.Runtime.shared.after(.zero) { runs += 1 }
            let token = memory.timers[0].token
            unsafe HTML.DOM.Runtime.shared.fire(token)
            unsafe HTML.DOM.Runtime.shared.fire(token)
            #expect(runs == 1)
        }
    }
#endif
