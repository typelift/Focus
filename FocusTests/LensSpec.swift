//
//  LensSpec.swift
//  Focus
//
//  Created by Robert Widmann on 7/4/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

import XCTest
import SwiftCheck
import Focus

class LensSpec : XCTestCase {
	func testLensLaws() {
		property("get-set") <- forAll { (fs : IsoOf<Int, UInt>) in
			let lens = Lens(get: fs.getTo, set: { _, v in fs.getFrom(v) })
			return forAll { (l : Int) in
				return lens.set(l, lens.get(l)) == l
			}
		}
		
		property("set-get") <- forAll { (fs : IsoOf<Int, UInt>) in
			let lens = Lens(get: fs.getTo, set: { _, v in fs.getFrom(v) })
			return forAll { (l : Int, a : UInt) in
				return lens.get(lens.set(l, a)) == a
			}
		}
		
		property("idempotent-set") <- forAll { (fs : IsoOf<Int, UInt>) in
			let lens = Lens(get: fs.getTo, set: { _, v in fs.getFrom(v) })
			return forAll { (l : Int, r : UInt, a : UInt) in
				return lens.set(lens.set(l, a), r) == lens.set(l, r)
			}
		}
		
		property("idempotent-identity") <- forAll { (fs : IsoOf<Int, UInt>) in
			let lens = Lens(get: fs.getTo, set: { _, v in fs.getFrom(v) })
			return forAll { (l : Int) in
				return lens.modify(l, { $0 }) == l
			}
		}
	}
}

class SimpleLensSpec : XCTestCase {
	func testLensLaws() {
		property("get-set") <- forAll { (fs : IsoOf<Int, UInt>) in
			let lens = SimpleLens(get: fs.getTo, set: { _, v in fs.getFrom(v) })
			return forAll { (l : Int) in
				return lens.set(l, lens.get(l)) == l
			}
		}
		
		property("set-get") <- forAll { (fs : IsoOf<Int, UInt>) in
			let lens = SimpleLens(get: fs.getTo, set: { _, v in fs.getFrom(v) })
			return forAll { (l : Int, a : UInt) in
				return lens.get(lens.set(l, a)) == a
			}
		}
		
		property("idempotent-set") <- forAll { (fs : IsoOf<Int, UInt>) in
			let lens = SimpleLens(get: fs.getTo, set: { _, v in fs.getFrom(v) })
			return forAll { (l : Int, r : UInt, a : UInt) in
				return lens.set(lens.set(l, a), r) == lens.set(l, r)
			}
		}
		
		property("idempotent-identity") <- forAll { (fs : IsoOf<Int, UInt>) in
			let lens = SimpleLens(get: fs.getTo, set: { _, v in fs.getFrom(v) })
			return forAll { (l : Int) in
				return lens.modify(l, { $0 }) == l
			}
		}
	}
}

func == <T : Equatable, U : Equatable>(l : (T, U), r : (T, U)) -> Bool {
	return l.0 == r.0 && l.1 == r.1
}

func uncurry<A, B, C>(f : A -> B -> C) -> (A, B) -> C {
	return { t in f(t.0)(t.1) }
}


func • <A, B, C>(f : B -> C, g: A -> B) -> A -> C {
	return { (a : A) -> C in
		return f(g(a))
	}
}
