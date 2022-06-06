import SwiftUI

public struct PreviewGroup<Content: View>: View {
    var content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        _VariadicView.Tree(PreviewGroupRoot(), content: content)
    }
}
