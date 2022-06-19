@testable import ViewSnapshotTesting
import XCTest
import SwiftUI

class viewNameWithoutModifiersTests: XCTestCase {
    func getName<V: View>(_ view: V) -> String {
        viewNameWithoutModifiers(type: V.self)
    }
    func testTextModifiedContent() {
        XCTAssertEqual("ModifiedContent<ModifiedContent<Text, _PaddingLayout>, _TraitWritingModifier<PreviewLayoutTraitKey>>", "\(type(of:SampleView_Previews.previewText))")
        XCTAssertEqual("Text", getName(SampleView_Previews.previewText))
    }
    func testTextTupleView() {
        XCTAssertEqual("Group<TupleView<(Text, Text)>>", "\(type(of:SampleView_Previews.previewGroup))")
        XCTAssertEqual("Text", getName(SampleView_Previews.previewGroup))
    }
    func testTextSingleTupleView() {
        XCTAssertEqual("Group<Text>", "\(type(of:SampleView_Previews.previewGroupSingle))")
        XCTAssertEqual("Text", getName(SampleView_Previews.previewGroupSingle))
    }
    func testTestSampleView() {
        XCTAssertEqual("Group<TupleView<(ModifiedContent<SampleView, _BackgroundModifier<Color>>, ModifiedContent<SampleView, _BackgroundModifier<Color>>)>>", "\(type(of:SampleView_Previews.previews))")
        XCTAssertEqual("SampleView", getName(SampleView_Previews.previews))
    }
    
}

extension SampleView_Previews {
    static var previewText: some View {
        Text("hi").padding(1).previewLayout(.sizeThatFits)
    }
    static var previewGroup: some View {
        Group {
            Text("one")
            Text("two")
        }
    }
    static var previewGroupSingle: some View {
        Group {
            Text("one")
        }
    }
}
