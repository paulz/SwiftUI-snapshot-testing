import SwiftUI

public struct PreviewGroup<Content: View>: View {
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    @ViewBuilder
    var content: ()->Content

    public var body: some View {
        _VariadicView.Tree(PreviewGroupRoot(), content: content)
    }
}
