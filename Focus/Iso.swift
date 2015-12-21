//
//  Iso.swift
//  swiftz
//
//  Created by Alexander Ronald Altman on 7/22/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// Captures an isomorphism between S, A and B, T.
///
/// In practice, an Iso is used with two structures that can be converted between each other without
/// information loss.  For example, the Isomorphism between `Optional<T>` and `CollectionOfOne<T?>`
/// is expressed as
///
///     Iso<Optional<T>, Optional<U>, CollectionOfOne<T?>, CollectionOfOne<U>>
///
/// If a less-powerful form of `Iso` is needed, or `S == T` and `A == B`, consider using a 
/// `SimpleIso` instead.
///
/// - parameter S: The source of the first function of the isomorphism.
/// - parameter T: The target of the second function of the isomorphism.
/// - parameter A: The target of the first function of the isomorphism.
/// - parameter B: The source of the second function of the isomorphism.
public struct Iso<S, T, A, B> : IsoType {
	public typealias Source = S
	public typealias Target = A
	public typealias AltSource = T
	public typealias AltTarget = B

	private let _get : S -> A
	private let _inject : B -> T

	/// Builds an Iso from a pair of inverse functions.
	public init(get f : S -> A, inject g : B -> T) {
		_get = f
		_inject = g
	}

	/// Extracts the first function from the isomorphism.
	public func get(v : S) -> A {
		return _get(v)
	}

	/// Extracts the second function from the isomorphism.
	public func inject(x : B) -> T {
		return _inject(x)
	}

	/// Extracts the two functions that characterize the receiving `Iso`.
	public func withIso<R>(k : ((S -> A), (B -> T)) -> R) -> R {
		return k(self.get, self.inject)
	}

	/// Returns the inverse `Iso` from the receiver.
	///
	/// self.invert.invert == self
	public var invert : Iso<B, A, T, S> {
		return self.withIso { sa, bt in
			return Iso<B, A, T, S>(get: bt, inject: sa)
		}
	}
}

/// Captures the essential structure of an `Iso`.
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

	/// An `Iso`'s `tryGet` will always succeed.
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
public func • <Left : IsoType, Right : IsoType where
	Left.Target == Right.Source,
	Left.AltTarget == Right.AltSource>
	(l : Left, r : Right) -> Iso<Left.Source, Left.AltSource, Right.Target, Right.AltTarget>
{
	return l.compose(r)
}
