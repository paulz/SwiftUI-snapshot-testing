import SwiftUI

struct SampleView: View {
    var body: some View {
        Group {
            Circle()
                .fill(.green.opacity(0.6))
            Rectangle()
                .fill(.blue.opacity(0.6))
        }
        .fixedSize()
        .frame(width: 30, height: 20)
    }
}
