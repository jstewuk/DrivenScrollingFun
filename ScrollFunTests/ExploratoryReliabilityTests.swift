//
//  ExploratoryReliabilityTests.swift
//  ScrollFunTests
//
//  Created by James Stewart on 4/27/20.
//  Copyright © 2020 James Stewart. All rights reserved.
//

import XCTest
import Combine

/**
 Can we use combine to simulate dropout from a stream, like a random filter that drops 10 percent of the values passed through?
 Strategy: zip 2 streams, V and R together where V is the value type, and R is random, compactMap from (V, R) to V based on R
 
 V ->
     .zip -> (R,V) .compactMap {  r < threshold? V, nil } -> V'
 R ->
 */

let count = 30

public struct RandomSeq: Sequence, IteratorProtocol {
    private var runningCount: Int = 0
    public let iCount: Int = count
    
    public mutating func next() -> Int? {
        guard runningCount < iCount else { return nil }
        return Int.random(in: 1..<10)
    }
}

class ExploratoryReliabilityTests: XCTestCase {
    
    func testCanCreateARandomStream() {
        /** random sequence */
        
        let seq = RandomSeq()
        
        var randomArray = [Int]()
        
        _ = seq.publisher
            .sink {
                randomArray.append($0)
            }
        
        func average(_ arr: [Int]) -> Double {
            let sum = arr.reduce(0) { $0 + $1 }
            return Double(sum) / Double(30.0)
        }
        
        XCTAssert(randomArray.count == 30)
        XCTAssert(average(randomArray) < 7 && average(randomArray) > 3)
    }


}
