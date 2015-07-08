//
//  PrismSpec.swift
//  Focus
//
//  Created by Robert Widmann on 7/4/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

import XCTest
import SwiftCheck
import Focus

class PrismSpec : XCTestCase {
    func testPrismLaws() {
		property("modify-identity") <- forAll { (fs : IsoOf<Int, UInt>, tryGet : ArrowOf<UInt, OptionalOf<UInt>>) in
			let prism = Prism<Int, Int, UInt, UInt>(tryGet: { $0.getOptional } • tryGet.getArrow • fs.getTo, inject: fs.getFrom)
			return forAll { (l : Int) in
				let m = prism.tryModify(l, { $0 })
				return m != nil ==> (m == l)
			}
		}
    }
}
