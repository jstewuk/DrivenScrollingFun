//
//  ReverseScrollView.swift
//  ScrollFun
//
//  Created by James Stewart on 4/18/20.
//  Copyright © 2020 James Stewart. All rights reserved.
//

import SwiftUI
import Combine
import os

struct ReverseScrollView<Content>: View where Content: View {
    
    @ObservedObject var model: ScrollViewModel
    
    var scrollOffset: Binding<CGFloat> { $model.scrollOffset }
    var contentHeight: Binding<CGFloat> { $model.contentHeight }
    var currentOffset: Binding<CGFloat> { $model.currentOffset }
    var content: () -> Content
    
    var body: some View {
        //os_log("ReversScrollView rerendered")
        return
            GeometryReader { outerGeometry in
            self.content()
                .modifier(ViewHeightKey())
                .onPreferenceChange(ViewHeightKey.self) { self.contentHeight.wrappedValue = $0 }
                .frame(height: outerGeometry.size.height)
                .offset(y: self.model.offset(outerHeight: outerGeometry.size.height, innerHeight: self.contentHeight.wrappedValue))
                .clipped()
                .animation(.easeInOut)
                .gesture(
                    DragGesture()
                        .onChanged { self.model.onDragChangedLocal(DragValue($0)) }
                        .onEnded { self.model.onDragEndedLocal(DragValue($0), outerHeight: outerGeometry.size.height)}
                )
        }
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
    static let inboundSubject = DragSubject()
    static let outboundSubject = DragSubject()
    static let model = ScrollViewModel("previewMode", inboundSubject: inboundSubject, outboundSubject: outboundSubject, latency: 0.1)
    static var previews: some View {
        ReverseScrollView(model: model) {
            BubbleView(message: "Hello")
        }
        .previewLayout(.sizeThatFits)
    }
}
