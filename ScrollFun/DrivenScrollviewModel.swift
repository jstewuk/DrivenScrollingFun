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

struct DragWrapper {
    let value: LocationDelta
    let outerSize: CGSize
}

struct LocationDelta {
    var delta: CGPoint
    init(_ value: DragGesture.Value) {
        delta = CGPoint(x: value.location.x - value.startLocation.x, y: value.location.y - value.startLocation.y)
    }
}

enum DragData {
    case dragEnded(DragWrapper)
    case dragChanged(DragWrapper)
}

typealias DragSubject = PassthroughSubject<DragData, Never>

final class DrivenScrollViewModel: ObservableObject {
    @Published var scrollOffset:  CGPoint = CGPoint.zero
    @Published var contentSize: CGSize = CGSize.zero
    @Published var currentOffset: CGPoint = CGPoint.zero
    
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
    
    private func onDragChangedRemote(_ value: DragWrapper) {
        onDragChanged(value)
    }
    
    func onDragChangedLocal(_ value: DragWrapper) {
        onDragChanged(value)
        let enabledValue = enabledValues(value)
        outboundSubject.send(.dragChanged(enabledValue))
    }
    
    private func onDragChanged(_ value: DragWrapper) {
        scrollOffset = enabledValues(value).value.delta
    }
    
    private func enabledValues(_ value: DragWrapper) -> DragWrapper {
        var filteredValue = CGPoint.zero
        if value.outerSize.width < contentSize.width && enabledAxes.contains(.horizontal) {
            filteredValue.x = value.value.delta.x
        }
        if value.outerSize.height < contentSize.height && enabledAxes.contains(.vertical) {
            filteredValue.y = value.value.delta.y
        }
        var locationDelta = value.value
        locationDelta.delta = filteredValue
        return DragWrapper(value: locationDelta, outerSize: value.outerSize)
    }
    
    private func onDragEndedRemote(_ value: DragWrapper) {
        onDragEnded(value)
    }
    
    func onDragEndedLocal(_ value: DragWrapper) {
        onDragEnded(value)
        let enabledValue = enabledValues(value)
        outboundSubject.send(.dragEnded(enabledValue))
    }
    
    private func onDragEnded(_ value: DragWrapper) {
        //os_log("%@ onDragEnded", self.instanceName)
        
        for axis in enabledAxes {
            if case .horizontal = axis {
                self.currentOffset.x = axisCurrentOffset(axis: axis, scrollOffset: value.value.delta, outerSize: value.outerSize, contentSize: contentSize)
            } else {
                self.currentOffset.y = axisCurrentOffset(axis: axis, scrollOffset: value.value.delta, outerSize: value.outerSize, contentSize: contentSize)
            }
        }
        //os_log("new currentOffset= %@", "\(self.currentOffset)")
        self.scrollOffset = CGPoint.zero
    }
    
    func axisCurrentOffset(axis: Axis, scrollOffset: CGPoint, outerSize: CGSize, contentSize: CGSize) -> CGFloat {
        let currentOffsetValue = self.currentOffset.axis(axis)
        let scrollOffsetValue = scrollOffset.axis(axis)
        let contentSizeValue = contentSize.axis(axis)
        let outerSizeValue = outerSize.axis(axis)
        
        if currentOffsetValue + scrollOffsetValue > 0 { // scrolled past top/left => clamp
            return .zero
        } else if currentOffsetValue + scrollOffsetValue <  -(contentSizeValue - outerSizeValue) { // scrolled past bottom/right => clamp
            return -(contentSizeValue - outerSizeValue)
        } else {                                // Normal in bounds scrolling
            return currentOffsetValue + scrollOffsetValue
        }
    }
    
    func offset(outerSize: CGSize, innerSize: CGSize) -> CGPoint {
        //os_log("outerHeight: %@ innerHeight: %@", "\(outerHeight)", "\(innerHeight)")
        var totalOffset = CGPoint.zero
        for axis in enabledAxes {
            if case .horizontal = axis {
                totalOffset.x = currentOffset.x + scrollOffset.x
            } else {
                totalOffset.y = currentOffset.y + scrollOffset.y
            }
        }
        return totalOffset - CGPoint(outerSize/2 - innerSize/2)
    }
}
