//
//  DrivenScrollView.swift
//  ScrollFun
//
//  Created by James Stewart on 4/18/20.
//  Copyright © 2020 James Stewart. All rights reserved.
//

import SwiftUI
import Combine
import os

struct DrivenScrollView<Content>: View where Content: View {
    
    @ObservedObject var model: DrivenScrollViewModel
    
    var scrollOffset: Binding<CGPoint> { $model.scrollOffset }
    var contentSize: Binding<CGSize> { $model.contentSize }
    var currentOffset: Binding<CGPoint> { $model.currentOffset }
    var content: () -> Content
    let enabledScrollAxes: [Axis] = [.vertical]
    
    init(enabledAxes: [Axis], inboundSubject: DragSubject, outboundSubject: DragSubject, @ViewBuilder content: @escaping () -> Content) {
        self.model = DrivenScrollViewModel("model", enabledAxes: enabledAxes, inboundSubject: inboundSubject, outboundSubject: outboundSubject)
        self.content = content
    }
    
    var body: some View {
        return
            GeometryReader { outerGeometry in
            self.content()
                .modifier(ViewSizeKey())
                .onPreferenceChange(ViewSizeKey.self) { self.contentSize.wrappedValue = $0 }
                .frame(width: outerGeometry.size.width, height: outerGeometry.size.height)
                .offset(
                    x: self.model.offset(outerSize: outerGeometry.size, innerSize: self.contentSize.wrappedValue).x,
                    y: self.model.offset(outerSize: outerGeometry.size, innerSize: self.contentSize.wrappedValue).y
                )
                .clipped()
                .animation(.easeInOut)
                .gesture(
                    DragGesture()
                        .onChanged {
                            self.model.onDragChangedLocal(DragWrapper(value: LocationDelta($0), outerSize: outerGeometry.size))
                        }
                        .onEnded {
                            self.model.onDragEndedLocal(DragWrapper(value: LocationDelta($0), outerSize: outerGeometry.size))
                        }
                )
        }
    }
}

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize { CGSize.zero }
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value += nextValue()
    }
}

extension ViewSizeKey: ViewModifier {
    func body(content: Content) -> some View {
        return content.background(GeometryReader { proxy in
            Color.clear.preference(key: Self.self, value: proxy.size)
        })
    }
}


struct DrivenScrolliew_Previews: PreviewProvider {
    static let inboundSubject = DragSubject()
    static let outboundSubject = DragSubject()
    static let model = DrivenScrollViewModel("previewMode", enabledAxes: [.horizontal], inboundSubject: inboundSubject, outboundSubject: outboundSubject, latency: 0.1)
    static var previews: some View {
        DrivenScrollView(enabledAxes: [.horizontal], inboundSubject: inboundSubject, outboundSubject: outboundSubject) {
            BubbleView(message: "Hello")
        }
        .previewLayout(.sizeThatFits)
    }
}
