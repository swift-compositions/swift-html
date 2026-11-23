import ECMA_262
import HTML_Rendering

extension String.StringInterpolation {
    public mutating func appendInterpolation(html value: some HTML.View) {
        let bytes = ContiguousArray(value)
        let htmlString: String = String(decoding: bytes, as: UTF8.self)
        appendLiteral(String(ECMA.`262`.Template.Literal(htmlString)))
    }
}
