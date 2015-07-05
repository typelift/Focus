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

// Don't use this, am out of my mind.
//extension Iso where S : protocol<Hashable, CoArbitrary>, T : Arbitrary, A : Arbitrary, B : protocol<Hashable, CoArbitrary> {
//    static func arbitrary() -> Gen<Iso<S, T, A, B>> {
//        return ArrowOf<S, A>.arbitrary().bind { g in
//            return ArrowOf<B, T>.arbitrary().bind { s in
//                let there = g.getArrow
//                let andBackAgain = s.getArrow
//                return Gen.pure(Iso(get: there, inject: andBackAgain))
//            }
//        }
//    }
//
//    static func shrink(_ : Iso<S, T, A, B>) -> [Iso<S, T, A, B>] {
//        return []
//    }
//}
