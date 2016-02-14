[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/typelift/Focus.svg?branch=master)](https://travis-ci.org/typelift/Focus)
[![Gitter chat](https://badges.gitter.im/DPVN/chat.png)](https://gitter.im/typelift/general?utm_source=share-link&utm_medium=link&utm_campaign=share-link)


Focus
=====

Focus is an Optics library for Swift (where Optics includes `Lens`,
`Prism`s, and `Iso`s) that is inspired by Haskell's
[Lens](https://github.com/ekmett/lens) library.

Introduction
============

Focus exports a number of primitives that make it easy to establish
*relations* between types.  Practically, a relation can be thought of
as a particular way of viewing and modifying a structure.  The most
famous of these is a `Lens` or Functional Reference.  While there are
an abundance of representations of a Lens (see
[[van Laarhoven 09](http://www.twanvl.nl/blog/haskell/cps-functional-references)],
[[Kmett et al. 12](http://lens.github.io)],
[[Eidhof et al. 09](https://hackage.haskell.org/package/fclabels)], we
have chosen a
[data-lens](https://hackage.haskell.org/package/data-lens)-like
implementation using the Indexed Store Comonad.  If all of that makes
no sense, don't worry!  We have hidden all of this behind a simple
interface.

Programming With Lenses
=======================

The easiest way to explain a lens is with a pair of functions

```swift
func get(structure : S) -> A
func set(pair : (self : S, newValue : A)) -> S
```

This should look quite familiar to you!  After all, Swift includes
syntax for this very pattern

```swift
final class Foo {
	var bar : Qux {
		get { //.. }
		set(newValue) { //.. }
	}
}
```

So what a lens actually lets you do is decouple the ability to *focus*
on particular bits and pieces of your data types. Moreover, lenses,
like properties, compose freely with other compatible lenses but with
normal function composition (denoted `•`) instead of the usual
dot-notation.  What sets Lenses apart from straight properties is
every part of the process is immutable.  A lens performs replacement
of the entire structure, a property performs replacement of a mutable
value within that structure.

All of these properties, flexibility immutability, and composability,
come together to enable a powerful set of operations that allow the
programmer to view a structure and its parts at any depth and any
angle, not simply those provided by properties.

Practical Lenses
================

For example, say we have this set of structures for working with a
flight tracking app:

```swift
import Foundation

enum Status {
	case Early
	case OnTime
	case Late
}

struct Plane {
	let model : String
	let freeSeats : UInt
	let takenSeats : UInt
	let status : Status
	var totalSeats : UInt {
		return self.freeSeats + self.takenSeats
	}
}

struct Gate {
	let number : UInt
	let letter : Character
}

struct BoardingPass {
	let plane : Plane
	let gate : Gate
	let departureDate : NSDate
	let arrivalDate : NSDate
}

```

Starting with a `BoardingPass`, getting our flight status is trivial

```swift
let plane = Plane(model: "SpaceX Raptor", freeSeats: 4, takenSeats: 0, status: .OnTime)
let gate = Gate(number: 1, letter: "A")
let pass = BoardingPass(plane: plane
					, gate: gate
					, departureDate: NSDate.distantFuture()
					, arrivalDate: NSDate.distantFuture())
let status = pass.plane.status
```

However, in order to update the status on the boarding pass without
lenses, we'd have to go through this rigamarole every time:

```swift
let oldPass = BoardingPass(/* */)
// Apparently, we're actually flying Allegiant
let newFlight = Plane(model: oldPass.plane.model
					, freeSeats: oldPass.plane.freeSeats
					, takenSeats: oldPass.plane.takenSeats
					, status: .Late)
let newPass = BoardingPass(plane: newFlight
						, gate: oldPass.gate
						, departureDate: oldPass.departureDate
						, arrivalDate: oldPass.arrivalDate)
```

After defining a few lenses, this is what we can do instead:

```swift
// The composite of two lenses is itself a lens
let newPass = (BoardingPass._plane • Plane._status).set(oldPass, .Late)
```

Here's the definition of those lenses:

```swift
extension BoardingPass {
	static var _plane : SimpleLens<BoardingPass, Plane> {
		return SimpleLens(get: {
			return $0.plane
		}, set: { (oldPass, newP) in
			return BoardingPass(plane: newP
							, gate: oldPass.gate
							, departureDate: oldPass.departureDate
							, arrivalDate: oldPass.arrivalDate)
		})
	}
}

extension Plane {
	static var _status : SimpleLens<Plane, Status> {
		return SimpleLens(get: {
			return $0.status
		}, set: { (oldP, newS) in
			return Plane( model: oldP.model
						, freeSeats: oldP.freeSeats
						, takenSeats: oldP.takenSeats
						, status: newS)
		})
	}
}
```


We've only scratched the surface of the power of Lenses, and we
haven't even touched the other members of the family of optics
exported by Focus.

System Requirements
===================

Focus supports OS X 10.9+ and iOS 8.0+.

License
=======

Focus is released under the MIT license.
