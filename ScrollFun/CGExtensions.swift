//
//  CGExtensions.swift
//  ScrollFun
//
//  Created by James Stewart on 4/29/20.
//  Copyright © 2020 James Stewart. All rights reserved.
//

import Foundation
import CoreGraphics
import SwiftUI

extension CGSize: AdditiveArithmetic {
    public static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(
            width: lhs.width + rhs.width,
            height: lhs.height + rhs.height
            
        )
    }
    
    public static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(
            width: lhs.width - rhs.width,
            height: lhs.height - rhs.height
            
        )
    }
}

extension CGSize {
    public static func / (lhs: Self, rhs: CGFloat) -> Self {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    
    public init(_ point: CGPoint) {
        self.init(
            width: point.x,
            height: point.y
        )
    }
    
    func axis(_ axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal:
            return self.width
        case .vertical:
            return self.height
        }
    }
}

extension CGPoint: AdditiveArithmetic {
    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(
            x: lhs.x + rhs.x,
            y: lhs.y + rhs.y
            
        )
    }
    
    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(
            x: lhs.x - rhs.x,
            y: lhs.y - rhs.y
        )
    }
}

extension CGPoint {
    public init(_ size: CGSize) {
        self.init(
            x: size.width,
            y: size.height
        )
    }
    
    func axis(_ axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal:
            return self.x
        case .vertical:
            return self.y
        }
    }
}

