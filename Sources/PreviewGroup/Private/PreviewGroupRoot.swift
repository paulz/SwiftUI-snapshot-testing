import SwiftUI

struct PreviewGroupRoot: _VariadicView_UnaryViewRoot {
    static var hosts: [UIViewController] = []
    
    static var elements: [_VariadicView.Children.Element] = []
    
    init() {
        Self.hosts = []
    }

    func body(children: _VariadicView.Children) -> some View {
        children.forEach {
            Self.elements.append($0)
            Self.hosts.append(UIHostingController(rootView: $0))
        }
        return children
    }
}
