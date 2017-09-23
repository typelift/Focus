//
//  PrismSpec.swift
//  Focus
//
//  Created by Robert Widmann on 7/4/15.
//  Copyright © 2015-2016 TypeLift. All rights reserved.
//

import XCTest
import SwiftCheck
import Focus
#if SWIFT_PACKAGE
	import Operadics
#endif

#if os(Linux)
	import Glibc
	public func randomInteger() -> UInt32 {
		return UInt32(rand())
	}
#else
	import Darwin

	public func randomInteger() -> UInt32 {
		return arc4random()
	}
#endif

class PrismSpec : XCTestCase {
	func testPrismLaws() {
		property("modify-identity") <- forAll { (fs : IsoOf<Int, UInt>) in
			/// Cannot generate this in the forAll because we need this to be memoizing and consistent with the Iso.
			let tryGet : (UInt) -> OptionalOf<UInt> = { randomInteger() % 4 == 0 ? OptionalOf(.none) : OptionalOf(.some($0)) }
			let prism = Prism(tryGet: { $0.getOptional } • tryGet • fs.getTo, inject: fs.getFrom)
			return forAll { (l : Int) in
				let m = prism.tryModify(l, { $0 })
				return m != nil ==> (m == l)
			}
		}
	}

	#if !os(macOS) && !os(iOS) && !os(tvOS)
	static var allTests = testCase([
		("testPrismLaws", testPrismLaws),
	])
	#endif
}

class SimplePrismSpec : XCTestCase {
	func testPrismLaws() {
		property("modify-identity") <- forAll { (fs : IsoOf<Int, UInt>) in
			/// Cannot generate this in the forAll because we need this to be memoizing and consistent with the Iso.
			let tryGet : (UInt) -> OptionalOf<UInt> = { randomInteger() % 4 == 0 ? OptionalOf(.none) : OptionalOf(.some($0)) }
			let prism = SimplePrism(tryGet: { $0.getOptional } • tryGet • fs.getTo, inject: fs.getFrom)
			return forAll { (l : Int) in
				let m = prism.tryModify(l, { $0 })
				return m != nil ==> (m == l)
			}
		}
	}

	#if !os(macOS) && !os(iOS) && !os(tvOS)
	static var allTests = testCase([
		("testPrismLaws", testPrismLaws),
	])
	#endif
}
