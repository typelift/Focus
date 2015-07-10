//
//  IsoSpec.swift
//  Focus
//
//  Created by Robert Widmann on 7/4/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

import XCTest
import SwiftCheck
import Focus

class IsoSpec : XCTestCase {
	func testIsoLaws() {
		property("around the world") <- forAll { (x : UInt, fs : IsoOf<Int, UInt>) in
			let iso = Iso<Int, Int, UInt, UInt>(get: fs.getTo, inject: fs.getFrom)
			return iso.get(iso.inject(x)) == x
		}
		
		property("and back again") <- forAll { (x : Int, fs : IsoOf<Int, UInt>) in
			let iso = Iso<Int, Int, UInt, UInt>(get: fs.getTo, inject: fs.getFrom)
			return iso.inject(iso.get(x)) == x
		}
		
		property("modify-identity") <- forAll { (x : Int, fs : IsoOf<Int, UInt>) in
			let iso = Iso<Int, Int, UInt, UInt>(get: fs.getTo, inject: fs.getFrom)
			return iso.modify(x, { $0 }) == x
		}
	}
}
