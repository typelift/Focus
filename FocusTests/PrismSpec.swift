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

/// For now, until I can think of a sensible way to generate Prisms.
let prismNilGen = Gen.pure(Prism<Int, Int, String, String>(tryGet: { _ in nil }, inject: { $0.characters.count }))

class PrismSpec : XCTestCase {
    func testPrismLaws() {
        property("modify-identity") <- forAllShrink(prismNilGen, shrinker: { _ in [] }) { prism in
            return forAll { (l : Int) in
                return prism.tryModify(l, { $0 }) == nil
            }
        }
    }
}
