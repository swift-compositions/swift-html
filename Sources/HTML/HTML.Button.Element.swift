import HTML_Standard
import WHATWG_HTML_Elements

extension HTML.Button.Element {
    @HTML.Builder
    public static func submit(
        disabled: HTML.Disabled.Attribute? = nil,
        form: HTML.Form.Attribute.ID? = nil,
        name: HTML.Name.Attribute? = nil,
        value: HTML.Value.Attribute<String>? = nil,
        autofocus: HTML.Autofocus.Attribute? = nil,
        formaction: HTML.FormAction.Attribute? = nil,
        formenctype: HTML.FormEncType.Attribute? = nil,
        formmethod: HTML.FormMethod.Attribute? = nil,
        formnovalidate: HTML.FormNovalidate.Attribute? = nil,
        formtarget: HTML.FormTarget.Attribute? = nil,
        popovertarget: HTML.PopoverTarget.Attribute? = nil,
        popovertargetaction: HTML.PopoverTargetAction.Attribute? = nil,
        @HTML.Builder content: () -> some HTML.View
    ) -> some HTML.View {
        HTML.Button.Element(
            type: .submit,
            disabled: disabled,
            form: form,
            name: name,
            value: value,
            autofocus: autofocus,
            formaction: formaction,
            formenctype: formenctype,
            formmethod: formmethod,
            formnovalidate: formnovalidate,
            formtarget: formtarget,
            popovertarget: popovertarget,
            popovertargetaction: popovertargetaction
        ) {
            content()
        }
    }
}
