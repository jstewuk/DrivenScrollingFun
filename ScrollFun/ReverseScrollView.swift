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

struct EndWrapper {
    let value: DragValue
    let outerHeight: CGFloat
}

struct DragValue {
    let startLocation: CGPoint
    let location: CGPoint
    init(_ value: DragGesture.Value) {
        self.startLocation = value.startLocation
        self.location = value.location
    }
}

enum DragData {
    case dragEnded(EndWrapper)
    case dragChanged(DragValue)
}

typealias DragSubject = PassthroughSubject<DragData, Never>

class ScrollViewModel: ObservableObject {
    @Published var scrollOffset:  CGFloat = CGFloat.zero
    @Published var contentHeight: CGFloat = CGFloat.zero
    @Published var currentOffset: CGFloat = CGFloat.zero
    
    @Published var dragGestureValue: DragGesture.Value?
    
    var latency: Double {
        didSet {
            self.setupPipes()
        }
    }
    
    let inboundSubject: DragSubject
    let outboundSubject : DragSubject
        
    var cancellables = [Cancellable]()
    private let instanceName: String
    
    init(_ instanceName: String, inboundSubject: DragSubject, outboundSubject: DragSubject, latency: Double = 0.0) {
        self.inboundSubject = inboundSubject
        self.outboundSubject = outboundSubject
        self.instanceName = instanceName
        self.latency = latency
        self.setupPipes()
    }
    
    private func setupPipes() {
        cancellables.removeAll()
        cancellables.append(
            inboundSubject
                .delay(for: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: latency), scheduler: DispatchQueue.main)
                .sink { (value) in
                    os_log("received update")
                    switch value {
                    case let .dragEnded(endWrapper):
                        self.onDragEndedRemote(endWrapper)
                    case let .dragChanged(value):
                        self.onDragChangedRemote(value)
                    }
            }
        )
    }
    
    
    
    private func onDragChangedRemote(_ value: DragValue) {
        onDragChanged(value)
    }
    
    func onDragChangedLocal(_ value: DragValue) {
        onDragChanged(value)
        outboundSubject.send(.dragChanged(value))
    }
    
    private func onDragChanged(_ value: DragValue) {
        // Update rendered offset
        os_log("Start: %@","\(value.startLocation.y)")
        os_log("Current: %@", "\(value.location.y)")
        scrollOffset = (value.location.y - value.startLocation.y)
        os_log("scrollOffset: %@", "\(self.scrollOffset)")
    }
    
    private func onDragEndedRemote(_ value: EndWrapper) {
        os_log("%@ onDragEndedRemote", self.instanceName)
        onDragEnded(value.value, outerHeight: value.outerHeight)
    }
    
    func onDragEndedLocal(_ value: DragValue, outerHeight: CGFloat) {
        os_log("$@ ondDragEndedLocal", self.instanceName)
        onDragEnded(value, outerHeight: outerHeight)
        outboundSubject.send(.dragEnded(EndWrapper(value: value, outerHeight: outerHeight)))
    }
    
    private func onDragEnded(_ value: DragValue, outerHeight: CGFloat) {
        // Update view to target position base on drag position
        os_log("%@ onDragEnded", self.instanceName)
        let scrollOffset = value.location.y - value.startLocation.y
        os_log("Ended currentOffset= %@  scrollOffset= %@", "\(self.currentOffset)", "\(scrollOffset)")
        
        let topLimit = self.contentHeight - outerHeight
        os_log("topLimit: %@", "\(topLimit)")
        
        // Negative topLimit => Content is smaller than screen size.  We reset the scroll position on drag end:
        if topLimit < 0 {
            self.currentOffset = 0
        } else {
            // We cannot pass the bottom limit (negative scroll)
            if self.currentOffset + scrollOffset < 0 {
                self.currentOffset = 0
            } else if self.currentOffset + scrollOffset > topLimit {
                self.currentOffset = topLimit
            } else {
                self.currentOffset += scrollOffset
            }
        }
        os_log("new currentOffset= %@", "\(self.currentOffset)")
        self.scrollOffset = 0
    }
    
    func offset(outerHeight: CGFloat, innerHeight: CGFloat) -> CGFloat {
        print("outerHeight: %@ innerHeight: %@", "\(outerHeight)", "\(innerHeight)")
        
        let totalOffset = currentOffset + scrollOffset
        return -((innerHeight/2 - outerHeight/2) - totalOffset)
    }
}

class DummyModel: ObservableObject {
    @Published var dummyVar: Int = 0
}

struct ReverseScrollView<Content>: View where Content: View {
    
    @ObservedObject var model: ScrollViewModel
    
    var scrollOffset: Binding<CGFloat> { $model.scrollOffset }
    var contentHeight: Binding<CGFloat> { $model.contentHeight }
    var currentOffset: Binding<CGFloat> { $model.currentOffset }
    var content: () -> Content
    
    var body: some View {
        print("ReversScrollView rerendered")
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
