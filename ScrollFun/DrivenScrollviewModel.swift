//
//  DrivenScrollViewModel.swift
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
    let value: LocationDelta
    let outerHeight: CGFloat
}

struct LocationDelta {
    let delta: CGPoint
    init(_ value: DragGesture.Value) {
        delta = CGPoint(x: value.location.x - value.startLocation.x, y: value.location.y - value.startLocation.y)
    }
}

enum DragData {
    case dragEnded(EndWrapper)
    case dragChanged(LocationDelta)
}

typealias DragSubject = PassthroughSubject<DragData, Never>

class DrivenScrollViewModel: ObservableObject {
    @Published var scrollOffset:  CGFloat = CGFloat.zero
    @Published var contentHeight: CGFloat = CGFloat.zero
    @Published var currentOffset: CGFloat = CGFloat.zero
    
    let enabledAxes: [Axis]
    
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
    
    init(_ instanceName: String, enabledAxes: [Axis], inboundSubject: DragSubject, outboundSubject: DragSubject,  latency: Double = 0.0, reliability: Int = 100) {
        self.enabledAxes = enabledAxes
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
    
    private func onDragChangedRemote(_ value: LocationDelta) {
        onDragChanged(value)
    }
    
    func onDragChangedLocal(_ value: LocationDelta) {
        onDragChanged(value)
        outboundSubject.send(.dragChanged(value))
    }
    
    private func onDragChanged(_ value: LocationDelta) {
        scrollOffset = value.delta.y
    }
    
    private func onDragEndedRemote(_ value: EndWrapper) {
        //os_log("%@ onDragEndedRemote", self.instanceName)
        onDragEnded(value.value, outerHeight: value.outerHeight)
    }
    
    func onDragEndedLocal(_ value: LocationDelta, outerHeight: CGFloat) {
        //os_log("$@ ondDragEndedLocal", self.instanceName)
        onDragEnded(value, outerHeight: outerHeight)
        outboundSubject.send(.dragEnded(EndWrapper(value: value, outerHeight: outerHeight)))
    }
    
    private func onDragEnded(_ value: LocationDelta, outerHeight: CGFloat) {
        //os_log("%@ onDragEnded", self.instanceName)
        let scrollOffset = value.delta.y
        //os_log("Ended currentOffset= %@  scrollOffset= %@", "\(self.currentOffset)", "\(scrollOffset)")
        
        if outerHeight >= contentHeight {  // Don't need to scroll at all
            self.currentOffset = 0
        } else if currentOffset + scrollOffset > 0 { // scrolled past top => clamp
            self.currentOffset = 0
        } else if currentOffset + scrollOffset <  -(contentHeight - outerHeight) { // scrolled past bottom => clamp
            self.currentOffset = -(contentHeight - outerHeight)
        } else {                                // Normal in bounds scrolling
            self.currentOffset += scrollOffset
        }
        //os_log("new currentOffset= %@", "\(self.currentOffset)")
        self.scrollOffset = 0
    }
    
    func offset(outerHeight: CGFloat, innerHeight: CGFloat) -> CGFloat {
        //os_log("outerHeight: %@ innerHeight: %@", "\(outerHeight)", "\(innerHeight)")
        let totalOffset = currentOffset + scrollOffset
        return totalOffset - (outerHeight/2 - innerHeight/2)
    }
}
