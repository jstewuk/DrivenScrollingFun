//
//  ReverseScrollView.swift
//  ScrollFun
//
//  Created by James Stewart on 4/18/20.
//  Copyright © 2020 James Stewart. All rights reserved.
//

import SwiftUI

struct ReverseScrollView<Content>: View where Content: View {
    var content: () -> Content
    
    @State private var contentHeight = CGFloat.zero
    @State private var currentOffset = CGFloat.zero
    @State private var scrollOffset = CGFloat.zero

    var body: some View {
        GeometryReader { outerGeometry in
            self.content()
                .modifier(ViewHeightKey())
                .onPreferenceChange(ViewHeightKey.self) { self.contentHeight = $0 }
                .frame(height: outerGeometry.size.height)
                .offset(y: self.offset(outerHeight: outerGeometry.size.height, innerHeight: self.contentHeight))
                .clipped()
                .animation(.easeInOut)
                .gesture(
                    DragGesture()
                        .onChanged { self.onDragChanged($0) }
                        .onEnded { self.onDragEnded($0, outerHeight: outerGeometry.size.height)}
                )
        }
    }
    
    func offset(outerHeight: CGFloat, innerHeight: CGFloat) -> CGFloat {
        print("outerHeight: \(outerHeight) innerHeight: \(innerHeight)")
        
        let totalOffset = currentOffset + scrollOffset
        return -((innerHeight/2 - outerHeight/2) - totalOffset)
    }
    
    func onDragChanged(_ value: DragGesture.Value) {
        // Update rendered offset
        print("Start: \(value.startLocation.y)")
        print("Current: \(value.location.y)")
        self.scrollOffset = (value.location.y - value.startLocation.y)
        print("scrollOffset: \(self.scrollOffset)")
    }
    
    func onDragEnded(_ value: DragGesture.Value, outerHeight: CGFloat) {
        // Update view to target position base on drag position
        let scrollOffset = value.location.y - value.startLocation.y
        print("Ended currentOffset=\(self.currentOffset) scrollOffset=\(scrollOffset)")
        
        let topLimit = self.contentHeight - outerHeight
        print("topLimit: \(topLimit)")
        
        // Negative topLimit => Content is smaller than screen size.  We reset the scroll position on drag end:
        if topLimit < 0 {
            self.currentOffset = 0
        } else {
            // We cannot pass the bottome limit (negative scroll)
            if self.currentOffset + scrollOffset < 0 {
                self.currentOffset = 0
            } else if self.currentOffset + scrollOffset > topLimit {
                self.currentOffset = topLimit
            } else {
                self.currentOffset += scrollOffset
            }
        }
        print("new currentOffset=\(self.currentOffset)")
        self.scrollOffset = 0
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

extension ViewHeightKey: ViewModifier {
    func body(content: Content) -> some View {
        return content.background(GeometryReader { proxy in
            Color.clear.preference(key: Self.self, value: proxy.size.height)
        })
    }
}


struct ReverseScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ReverseScrollView {
            BubbleView(message: "Hello")
        }
        .previewLayout(.sizeThatFits)
    }
}
