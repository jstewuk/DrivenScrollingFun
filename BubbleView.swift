//
//  BubbleView.swift
//  ScrollFun
//
//  Created by James Stewart on 4/18/20.
//  Copyright © 2020 James Stewart. All rights reserved.
//

import SwiftUI

struct BubbleView: View {
    var message: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(message)
            Spacer()
        }
        .padding(10)
        .background(Color.gray)
        //.frame(width: 500)
    }
}

struct BubbleView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleView(message: "Hello")
            .previewLayout(.sizeThatFits)
    }
}
