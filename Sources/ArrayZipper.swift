//
//  ArrayZipper.swift
//  swiftz
//
//  Created by Alexander Ronald Altman on 8/4/14.
//  Copyright (c) 2014 Maxwell Swadling. All rights reserved.
//

#if !XCODE_BUILD
	import Operadics
#endif

/// An `ArrayZipper` is a structure for walking an array of values and 
/// manipulating it in constant time.
/// 
/// Zippers are convenient ways of traversing and modifying a structure using a 
/// cursor to focus on its individual parts.
public struct ArrayZipper<A> : ExpressibleByArrayLiteral {
	public typealias Element = A

	/// The underlying array of values.
	public let values : [A]
	/// The position of the cursor within the Array.
	public let position : Int

	public init(_ values : [A] = [], _ position : Int = 0) {
		if position < 0 {
			self.position = 0
		} else if position >= values.count {
			self.position = values.count - 1
		} else {
			self.position = position
		}
		self.values = values
	}

	/// Creates an ArrayZipper pointing at the head of a given list of elements.
	public init(arrayLiteral elements : Element...) {
		self.init(elements, 0)
	}

	/// Creates an `ArrayZipper` with the cursor adjusted by n in the direction 
	/// of the sign of the given value.
	public func move(_ n : Int = 1) -> ArrayZipper<A> {
		return ArrayZipper(values, position + n)
	}

	/// Creates an `ArrayZipper` with the cursor set to a given position value.
	public func moveTo(_ pos : Int) -> ArrayZipper<A> {
		return ArrayZipper(values, pos)
	}

	/// Returns whether the cursor of the receiver is at the end of its 
	/// underlying Array.
	public var isAtEnd : Bool {
		return position >= (values.count - 1)
	}
}

extension ArrayZipper /*: Functor*/ {
	public func map<B>(_ f : (A) -> B) -> ArrayZipper<B> {
		return ArrayZipper<B>(self.values.map(f), self.position)
	}
}

public func <^> <A, B>(f : (A) -> B, xz : ArrayZipper<A>) -> ArrayZipper<B> {
	return xz.map(f)
}

extension ArrayZipper /*: Copointed*/ {
	/// Extracts the value at the position of the receiver's cursor.
	///
	/// This function is not total, but makes the guarantee that if 
	/// `zipper.isAtEnd` returns false it is safe to call.
	public func extract() -> A {
		return self.values[self.position]
	}
}

extension ArrayZipper /*: Comonad*/ {
	public func duplicate() -> ArrayZipper<ArrayZipper<A>> {
		return ArrayZipper<ArrayZipper<A>>((0 ..< self.values.count).map { ArrayZipper(self.values, $0) }, self.position)
	}

	public func extend<B>(_ f : (ArrayZipper<A>) -> B) -> ArrayZipper<B> {
		return ArrayZipper<B>((0 ..< self.values.count).map { f(ArrayZipper(self.values, $0)) }, self.position)
	}
}

public func ->> <A, B>(xz : ArrayZipper<A>, f: (ArrayZipper<A>) -> B) -> ArrayZipper<B> {
	return xz.extend(f)
}
