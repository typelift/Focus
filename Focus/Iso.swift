//
//  Iso.swift
//  swiftz
//
//  Created by Alexander Ronald Altman on 7/22/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// Captures an isomorphism between S and A.
///
/// - parameter S: The source of the Iso heading right
/// - parameter T: The target of the Iso heading left
/// - parameter A: The source of the Iso heading right
/// - parameter B: The target of the Iso heading left
public struct Iso<S, T, A, B> {
	public let get : S -> A
	public let inject : B -> T

	/// Builds an Iso from a pair of inverse functions.
	public init(get : S -> A, inject : B -> T) {
		self.get = get
		self.inject = inject
	}

	/// Runs a value of type `S` along both parts of the Iso.
	public func modify(v : S, _ f : A -> B) -> T {
		return inject(f(get(v)))
	}

	/// Composes an `Iso` with the receiver.
	public func compose<I, J>(i2 : Iso<A, B, I, J>) -> Iso<S, T, I, J> {
		return self • i2
	}
	
	/// Converts an Iso to a Lens.
	public var asLens : Lens<S, T, A, B> {
		return Lens { s in IxStore(self.get(s)) { self.inject($0) } }
	}
	
	/// Converts an Iso to a Prism with a getter that always succeeds..
	public var asPrism : Prism<S, T, A, B> {
		return Prism(tryGet: { .Some(self.get($0)) }, inject: inject)
	}
}

/// The identity isomorphism.
public func identity<S, T>() -> Iso<S, T, S, T> {
	return Iso(get: identity, inject: identity)
}

/// Compose isomorphisms.
public func • <S, T, I, J, A, B>(i1 : Iso<S, T, I, J>, i2 : Iso<I, J, A, B>) -> Iso<S, T, A, B> {
	return Iso(get: i2.get • i1.get, inject: i1.inject • i2.inject)
}
