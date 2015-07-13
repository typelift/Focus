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
public struct Iso<S, T, A, B> : IsoType {
	typealias Source = S
	typealias Target = A
	typealias AltSource = T
	typealias AltTarget = B

	private let _get : S -> A
	private let _inject : B -> T

	/// Builds an Iso from a pair of inverse functions.
	public init(get f : S -> A, inject g : B -> T) {
		_get = f
		_inject = g
	}

	public func get(v : S) -> A {
		return _get(v)
	}

	public func inject(x : B) -> T {
		return _inject(x)
	}
}

public protocol IsoType : OpticFamilyType, LensType, PrismType {
	func get(_ : Source) -> Target
	func inject(_ : AltTarget) -> AltSource
}

extension Iso {
	public init<Other : IsoType where
		S == Other.Source, A == Other.Target, T == Other.AltSource, B == Other.AltTarget>
		(_ other : Other)
	{
		self.init(get: other.get, inject: other.inject)
	}
}

/// The identity isomorphism.
public func identity<S, T>() -> Iso<S, T, S, T> {
	return Iso(get: identity, inject: identity)
}

extension IsoType {
	public func run(v : Source) -> IxStore<Target, AltTarget, AltSource> {
		return IxStore<Target, AltTarget, AltSource>(get(v)) { x in
			return self.inject(x)
		}
	}

	public func tryGet(v : Source) -> Target? {
		return get(v)
	}

	/// Runs a value of type `S` along both parts of the Iso.
	public func modify(v : Source, _ f : Target -> AltTarget) -> AltSource {
		return inject(f(get(v)))
	}

	/// Composes an `Iso` with the receiver.
	public func compose<Other : IsoType where
		Self.Target == Other.Source,
		Self.AltTarget == Other.AltSource>
		(other : Other) -> Iso<Source, AltSource, Other.Target, Other.AltTarget>
	{
		return Iso(get: other.get • self.get, inject: self.inject • other.inject)
	}
}

/// Compose isomorphisms.
public func • <Left : IsoType, Right: IsoType where
	Left.Target == Right.Source,
	Left.AltTarget == Right.AltSource>
	(l : Left, r : Right) -> Iso<Left.Source, Left.AltSource, Right.Target, Right.AltTarget>
{
	return l.compose(r)
}
