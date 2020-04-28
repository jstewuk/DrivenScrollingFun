//
//  ReverseScrollViewModel.swift
//  ScrollFun
//
//  Created by James Stewart on 4/28/20.
//  Copyright © 2020 James Stewart. All rights reserved.
//

import Foundation
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
            self.setupStreams()
        }
    }
    
    var reliability: Int {
        didSet {
            self.setupStreams()
        }
    }
    
    let inboundSubject: DragSubject
    let outboundSubject : DragSubject
        
    var cancellables = [Cancellable]()
    private let instanceName: String
    
    init(_ instanceName: String, inboundSubject: DragSubject, outboundSubject: DragSubject, latency: Double = 0.0, reliability: Int = 100) {
        self.inboundSubject = inboundSubject
        self.outboundSubject = outboundSubject
        self.instanceName = instanceName
        self.latency = latency
        self.reliability = reliability
        self.setupStreams()
    }
    
    private func setupStreams() {
         cancellables.removeAll()
        cancellables.append(
            inboundSubject
                .delay(for: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: latency), scheduler: DispatchQueue.main)
                .filter { _  in
                    reliability_(reliability: self.reliability)
                }
                .sink { (value) in
                    //os_log("received update")
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
        //os_log("Start: %@","\(value.startLocation.y)")
        //os_log("Current: %@", "\(value.location.y)")
        scrollOffset = (value.location.y - value.startLocation.y)
        //os_log("scrollOffset: %@", "\(self.scrollOffset)")
    }
    
    private func onDragEndedRemote(_ value: EndWrapper) {
        //os_log("%@ onDragEndedRemote", self.instanceName)
        onDragEnded(value.value, outerHeight: value.outerHeight)
    }
    
    func onDragEndedLocal(_ value: DragValue, outerHeight: CGFloat) {
        //os_log("$@ ondDragEndedLocal", self.instanceName)
        onDragEnded(value, outerHeight: outerHeight)
        outboundSubject.send(.dragEnded(EndWrapper(value: value, outerHeight: outerHeight)))
    }
    
    private func onDragEnded(_ value: DragValue, outerHeight: CGFloat) {
        // Update view to target position base on drag position
        //os_log("%@ onDragEnded", self.instanceName)
        let scrollOffset = value.location.y - value.startLocation.y
        //os_log("Ended currentOffset= %@  scrollOffset= %@", "\(self.currentOffset)", "\(scrollOffset)")
        
        let topLimit = self.contentHeight - outerHeight
        //os_log("topLimit: %@", "\(topLimit)")
        
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
        //os_log("new currentOffset= %@", "\(self.currentOffset)")
        self.scrollOffset = 0
    }
    
    func offset(outerHeight: CGFloat, innerHeight: CGFloat) -> CGFloat {
        //os_log("outerHeight: %@ innerHeight: %@", "\(outerHeight)", "\(innerHeight)")
        
        let totalOffset = currentOffset + scrollOffset
        return -((innerHeight/2 - outerHeight/2) - totalOffset)
    }
}

class DummyModel: ObservableObject {
    @Published var dummyVar: Int = 0
}
