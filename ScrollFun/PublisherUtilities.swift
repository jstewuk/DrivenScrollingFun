//
//  PublisherUtilities.swift
//  ScrollFun
//
//  Created by James Stewart on 4/28/20.
//  Copyright © 2020 James Stewart. All rights reserved.
//

import Foundation

/** filter predicate */
func reliability_(reliability: Int) -> Bool {
    guard reliability < 100 else { return true }
    return Int.random(in: 1...100) <= reliability
}

/**
  Example:
 ```
func testFilterImplementation() {
    let seqOf1s = [Int](repeating: 1, count: 100)
    
    var result = [Int]()
    let reliability = 90
    _ = seqOf1s.publisher
        .filter{ _  in
            reliability_(reliability: reliability)
        }
    .sink { result.append($0) }

    let tolerance = 5
    XCTAssert(result.count >= reliability - tolerance && result.count <= reliability + tolerance, "result has \(result.count) values")
}
 ```
 */

