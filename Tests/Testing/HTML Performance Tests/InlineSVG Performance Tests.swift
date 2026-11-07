import HTML
import SVG
import SVG_Standard
import Testing

enum `InlineSVG Performance Tests` {}

extension `InlineSVG Performance Tests` {
    @Suite(.serialized)
    struct InlineSVGPerformance {

        @Test(.timed())
        func `rendering simple HTML elements to String`() throws {
            for _ in 0..<1_000 {
                let view = div {
                    h1 { "Title" }
                    p { "Paragraph content" }
                    ul {
                        li { "Item 1" }
                        li { "Item 2" }
                        li { "Item 3" }
                    }
                }
                _ = try String(view)
            }
        }

        @Test(.timed())
        func `rendering HTML document with CSS styles`() throws {
            for _ in 0..<500 {
                let document = HTML.Document {
                    div {
                        h1 { "Styled Page" }
                            .css
                            .fontSize(.rem(2))
                            .color(DarkModeColor(light: .hex("333333"), dark: .hex("cccccc")))

                        p { "Content with styling" }
                            .css
                            .lineHeight(1.6)
                            .padding(.px(16))
                            .margin(.px(8))
                    }
                    .css
                    .maxWidth(.px(800))
                    .margin(.auto)
                }
                _ = try String(document)
            }
        }

        @Test(.timed())
        func `rendering InlineSVG to HTML String`() throws {
            for _ in 0..<1_000 {
                let view = div {
                    InlineSVG {
                        svg(width: 100, height: 100) {
                            circle(cx: .init(50), cy: .init(50), r: .init(40))
                                .fill("red")
                                .stroke("black")
                                .strokeWidth(2)
                        }
                    }
                }
                _ = try String(view)
            }
        }

        @Test(.timed())
        func `SVG to base64 data URI encoding`() throws {
            let svgContent = svg(width: 100, height: 100) {
                circle(cx: .init(50), cy: .init(50), r: .init(40))
                    .fill("blue")
                    .stroke("navy")
                    .strokeWidth(3)
                rect(x: .init(10), y: .init(10), width: .init(30), height: .init(30))
                    .fill("green")
            }

            for _ in 0..<1_000 {
                let view = img(svg: svgContent, alt: "Test SVG", base64: true)
                _ = try String(view)
            }
        }

        @Test(.timed())
        func `ContiguousArray byte rendering`() {
            for _ in 0..<1_000 {
                let view = div {
                    h1 { "Heading" }
                    p { "Paragraph" }
                    span { "Inline content" }
                }
                _ = ContiguousArray(view)
            }
        }
    }
}
