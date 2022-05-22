//
//  FavoriteView.swift
//  Experiments
//
//  Created by Paul Zabelin on 5/18/22.
//

import SwiftUI

/// https://www.hackingwithswift.com/articles/226/5-steps-to-better-swiftui-views
struct FavoriteView: View {
    var body: some View {
        Image(systemName: "heart.fill")
            .foregroundColor(.white)
            .padding()
            .background(Color.red)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(Color.white, lineWidth: 2)
            )
    }
}


struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView()
            .previewLayout(.sizeThatFits)
    }
}
