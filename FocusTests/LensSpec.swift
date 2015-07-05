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

/// For now, until I can think of a sensible way to generate Lenses.
let lensGen = Gen.pure(Lens<(Int, UInt), (Int, UInt), UInt, UInt>(get: { $0.1 }, set: { t, v in (t.0, v) }))

class LensSpec : XCTestCase {
    func testLensLaws() {
        property("get-set") <- forAllShrink(lensGen, shrinker: { _ in [] }) { lens in
            return forAll { (l : Int, r : UInt) in
                let s = (l, r)
                return lens.set(s, lens.get(s)) == s
            }
        }
        
        property("set-get") <- forAllShrink(lensGen, shrinker: { _ in [] }) { lens in
            return forAll { (l : Int, r : UInt, a : UInt) in
                let s = (l, r)
                return lens.get(lens.set(s, a)) == a
            }
        }
        
        property("idempotent-set") <- forAllShrink(lensGen, shrinker: { _ in [] }) { lens in
            return forAll { (l : Int, r : UInt, a : UInt) in
                let s = (l, r)
                return lens.set(lens.set(s, a), a) == lens.set(s, a)
            }
        }
        
        property("idempotent-identity") <- forAllShrink(lensGen, shrinker: { _ in [] }) { lens in
            return forAll { (l : Int, r : UInt) in
                let s = (l, r)
                return lens.modify(s, { $0 }) == s
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
