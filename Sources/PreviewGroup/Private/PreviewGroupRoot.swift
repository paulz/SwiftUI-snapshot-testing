import SwiftUI

struct PreviewGroupRoot: _VariadicView_UnaryViewRoot {
    static var elements: [_VariadicView.Children.Element] = []
    
    init() {
        Self.elements = []
    }

    func body(children: _VariadicView.Children) -> some View {
        children.forEach {
            Self.elements.append($0)
        }
        return children
    }
}
