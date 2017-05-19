//
//  IsoSpec.swift
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

class IsoSpec : XCTestCase {
	func testIsoLaws() {
		property("around the world") <- forAll { (x : UInt, fs : IsoOf<Int, UInt>) in
			let iso = Iso(get: fs.getTo, inject: fs.getFrom)
			return iso.get(iso.inject(x)) == x
		}
		
		property("and back again") <- forAll { (x : Int, fs : IsoOf<Int, UInt>) in
			let iso = Iso(get: fs.getTo, inject: fs.getFrom)
			return iso.inject(iso.get(x)) == x
		}
		
		property("modify-identity") <- forAll { (x : Int, fs : IsoOf<Int, UInt>) in
			let iso = Iso<Int, Int, UInt, UInt>(get: fs.getTo, inject: fs.getFrom)
			return iso.modify(x, { $0 }) == x
		}
		
		property("compose is associative (get)") <- forAll { (x : Int, fs : IsoOf<Int, Int>, gs : IsoOf<Int, Int>) in
			let iso1 = Iso(get: fs.getTo, inject: fs.getFrom)
			let iso2 = Iso(get: gs.getTo, inject: gs.getFrom)
			let isoC = iso1.compose(iso2)
			return iso2.get(iso1.get(x)) == isoC.get(x)
		}
		
		property("compose is associative (inject)") <- forAll { (x : Int, fs : IsoOf<Int, Int>, gs : IsoOf<Int, Int>) in
			let iso1 = Iso(get: fs.getTo, inject: fs.getFrom)
			let iso2 = Iso(get: gs.getTo, inject: gs.getFrom)
			let isoC = iso1.compose(iso2)
			return iso1.inject(iso2.inject(x)) == isoC.inject(x)
		}
	}

	func testIsoInverseLaws() {
		property("around the world") <- forAll { (x : UInt, fs : IsoOf<Int, UInt>) in
			let iso = Iso(get: fs.getTo, inject: fs.getFrom).invert.invert
			return iso.get(iso.inject(x)) == x
		}

		property("and back again") <- forAll { (x : Int, fs : IsoOf<Int, UInt>) in
			let iso = Iso(get: fs.getTo, inject: fs.getFrom).invert.invert
			return iso.inject(iso.get(x)) == x
		}

		property("modify-identity") <- forAll { (x : Int, fs : IsoOf<Int, UInt>) in
			let iso = Iso<Int, Int, UInt, UInt>(get: fs.getTo, inject: fs.getFrom).invert.invert
			return iso.modify(x, { $0 }) == x
		}

		property("compose is associative (get)") <- forAll { (x : Int, fs : IsoOf<Int, Int>, gs : IsoOf<Int, Int>) in
			let iso1 = Iso(get: fs.getTo, inject: fs.getFrom).invert.invert
			let iso2 = Iso(get: gs.getTo, inject: gs.getFrom).invert.invert
			let isoC = iso1.compose(iso2)
			return iso2.get(iso1.get(x)) == isoC.get(x)
		}

		property("compose is associative (inject)") <- forAll { (x : Int, fs : IsoOf<Int, Int>, gs : IsoOf<Int, Int>) in
			let iso1 = Iso(get: fs.getTo, inject: fs.getFrom).invert.invert
			let iso2 = Iso(get: gs.getTo, inject: gs.getFrom).invert.invert
			let isoC = iso1.compose(iso2)
			return iso1.inject(iso2.inject(x)) == isoC.inject(x)
		}
	}

	#if !os(macOS) && !os(iOS) && !os(tvOS)
	static var allTests = testCase([
		("testIsoLaws", testIsoLaws),
		("testIsoInverseLaws", testIsoInverseLaws),
	])
	#endif
}


class SimpleIsoSpec : XCTestCase {
	func testIsoLaws() {
		property("around the world") <- forAll { (x : UInt, fs : IsoOf<Int, UInt>) in
			let iso = SimpleIso(get: fs.getTo, inject: fs.getFrom)
			return iso.get(iso.inject(x)) == x
		}
		
		property("and back again") <- forAll { (x : Int, fs : IsoOf<Int, UInt>) in
			let iso = SimpleIso(get: fs.getTo, inject: fs.getFrom)
			return iso.inject(iso.get(x)) == x
		}
		
		property("modify-identity") <- forAll { (x : Int, fs : IsoOf<Int, UInt>) in
			let iso = Iso<Int, Int, UInt, UInt>(get: fs.getTo, inject: fs.getFrom)
			return iso.modify(x, { $0 }) == x
		}

		property("compose is associative (get)") <- forAll { (x : Int, fs : IsoOf<Int, Int>, gs : IsoOf<Int, Int>) in
			let iso1 = SimpleIso(get: fs.getTo, inject: fs.getFrom)
			let iso2 = SimpleIso(get: gs.getTo, inject: gs.getFrom)
			let isoC = iso1.compose(iso2)
			return iso2.get(iso1.get(x)) == isoC.get(x)
		}

		property("compose is associative (inject)") <- forAll { (x : Int, fs : IsoOf<Int, Int>, gs : IsoOf<Int, Int>) in
			let iso1 = SimpleIso(get: fs.getTo, inject: fs.getFrom)
			let iso2 = SimpleIso(get: gs.getTo, inject: gs.getFrom)
			let isoC = iso1.compose(iso2)
			return iso1.inject(iso2.inject(x)) == isoC.inject(x)
		}
	}

	func testIsoInverseLaws() {
		property("around the world") <- forAll { (x : UInt, fs : IsoOf<Int, UInt>) in
			let iso = SimpleIso(get: fs.getTo, inject: fs.getFrom).invert.invert
			return iso.get(iso.inject(x)) == x
		}

		property("and back again") <- forAll { (x : Int, fs : IsoOf<Int, UInt>) in
			let iso = SimpleIso(get: fs.getTo, inject: fs.getFrom).invert.invert
			return iso.inject(iso.get(x)) == x
		}

		property("modify-identity") <- forAll { (x : Int, fs : IsoOf<Int, UInt>) in
			let iso = Iso<Int, Int, UInt, UInt>(get: fs.getTo, inject: fs.getFrom).invert.invert
			return iso.modify(x, { $0 }) == x
		}

		property("compose is associative (get)") <- forAll { (x : Int, fs : IsoOf<Int, Int>, gs : IsoOf<Int, Int>) in
			let iso1 = SimpleIso(get: fs.getTo, inject: fs.getFrom).invert.invert
			let iso2 = SimpleIso(get: gs.getTo, inject: gs.getFrom).invert.invert
			let isoC = iso1.compose(iso2)
			return iso2.get(iso1.get(x)) == isoC.get(x)
		}

		property("compose is associative (inject)") <- forAll { (x : Int, fs : IsoOf<Int, Int>, gs : IsoOf<Int, Int>) in
			let iso1 = SimpleIso(get: fs.getTo, inject: fs.getFrom).invert.invert
			let iso2 = SimpleIso(get: gs.getTo, inject: gs.getFrom).invert.invert
			let isoC = iso1.compose(iso2)
			return iso1.inject(iso2.inject(x)) == isoC.inject(x)
		}
	}

	#if !os(macOS) && !os(iOS) && !os(tvOS)
	static var allTests = testCase([
		("testIsoLaws", testIsoLaws),
		("testIsoInverseLaws", testIsoInverseLaws),
	])
	#endif
}
