//
//  SampleView.swift
//  Experiments
//
//  Created by Paul Zabelin on 5/11/22.
//

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
