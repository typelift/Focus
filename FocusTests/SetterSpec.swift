//
//  SetterSpec.swift
//  Focus
//
//  Created by Ryan Peck on 3/18/16.
//  Copyright © 2016 TypeLift. All rights reserved.
//

import XCTest
import SwiftCheck
import Focus

class SetterSpec : XCTestCase {
    func testSetterLaws() {
        property("preserves-identity") <- forAll { (fs : IsoOf<Int, UInt>) in
            let lens = Lens(get: fs.getTo, set: { _, v in fs.getFrom(v) })
            let setter = Setter(over: { f in { s in lens.modify(s, f) } })
            return forAll { (l : Int) in
                return setter.over({ $0 })(l) == l
            }
        }

        property("preserves-composition") <- forAll { (fs : IsoOf<Int, UInt>) in
            let lens = Lens(get: fs.getTo, set: { _, v in fs.getFrom(v) })
            let setter = Setter(over: { f in { s in lens.modify(s, f) } })

            let f : UInt -> UInt = { $0 + 1 }
            let g : UInt -> UInt = { $0 * 2 }

            return forAll { (l : Int) in
                return (setter.over(f) • setter.over(g))(l) == setter.over(f • g)(l)
            }
        }
    }
}

class SimpleSetterSpec : XCTestCase {
    func testSetterLaws() {
        property("preserves-identity") <- forAll { (fs : IsoOf<Int, UInt>) in
            let lens = Lens(get: fs.getTo, set: { _, v in fs.getFrom(v) })
            let setter = SimpleSetter(over: { f in { s in lens.modify(s, f) } })
            return forAll { (l : Int) in
                return setter.over({ $0 })(l) == l
            }
        }

        property("preserves-composition") <- forAll { (fs : IsoOf<Int, UInt>) in
            let lens = Lens(get: fs.getTo, set: { _, v in fs.getFrom(v) })
            let setter = SimpleSetter(over: { f in { s in lens.modify(s, f) } })

            let f : UInt -> UInt = { $0 + 1 }
            let g : UInt -> UInt = { $0 * 2 }

            return forAll { (l : Int) in
                return (setter.over(f) • setter.over(g))(l) == setter.over(f • g)(l)
            }
        }
    }
}
