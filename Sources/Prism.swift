//
//  Prism.swift
//  swiftz
//
//  Created by Alexander Ronald Altman on 7/22/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

#if !XCODE_BUILD
	import Operadics
#endif

/// A `Prism` describes a way of focusing on potentially more than one target 
/// structure.  Like an `Iso` a `Prism` is invertible, but unlike an `Iso` 
/// multi-focus `Prism`s are incompatible with inversion in general.  Because of
/// this a `Prism` can branch depending on whether it hits its  target, much 
/// like pattern-matching in a `switch` statement.
///
/// An famous example of a `Prism` is
///
///     Prism<Optional<T>, Optional<T>, T, T>
///
/// provided by the `_Some` `Prism` in this library.
///
/// In practice, a `Prism` is used with Sum structures like enums. If a less
/// powerful form of `Prism` is needed, where `S == T` and `A == B`, consider 
/// using a `SimplePrism` instead.
public typealias SimplePrism<S, A> = Prism<S, S, A, A>
///
/// A Prism can thought of as an `Iso` characterized by two functions (where one
/// of the functions is partial):
///
/// - `tryGet` to possibly retrieve a focused part of the structure.
/// - `inject` to perform a "reverse get" back to a modified form of the 
///   original structure.
///
/// - parameter S: The source of the Prism
/// - parameter T: The modified source of the Prism
/// - parameter A: The possible target of the Prism
/// - parameter B: The modified target the Prism
public struct Prism<S, T, A, B> : PrismType {
	public typealias Source = S
	public typealias Target = A
	public typealias AltSource = T
	public typealias AltTarget = B

	private let _tryGet : (S) -> A?
	private let _inject : (B) -> T

	public init(tryGet f : @escaping (S) -> A?, inject g : @escaping (B) -> T) {
		_tryGet = f
		_inject = g
	}

	/// Attempts to focus the prism on the given source.
	public func tryGet(_ v : Source) -> Target? {
		return _tryGet(v)
	}

	/// Injects a value back into a modified form of the original structure.
	public func inject(_ x : AltTarget) -> AltSource {
		return _inject(x)
	}
}

public protocol PrismType : OpticFamilyType {
	func tryGet(_ : Source) -> Target?
	func inject(_ : AltTarget) -> AltSource
}

extension Prism {
	public init<Other : PrismType>(_ other : Other) where
		S == Other.Source, A == Other.Target, T == Other.AltSource, B == Other.AltTarget
	{
		self.init(tryGet: other.tryGet, inject: other.inject)
	}
}

/// Provides a Prism for tweaking values inside `.Some`.
public func _Some<A, B>() -> Prism<A?, B?, A, B> {
	return Prism(tryGet: identity, inject: Optional<B>.some)
}

/// Provides a Prism for traversing `.None`.
public func _None<A>() -> Prism<A?, A?, (), ()> {
	return Prism(tryGet: { _ in .none }, inject: { _ in .none })
}

extension PrismType {
	/// Composes a `Prism` with the receiver.
	public func compose<Other : PrismType>
		(_ other : Other) -> Prism<Source, AltSource, Other.Target, Other.AltTarget> where
		Self.Target == Other.Source,
		Self.AltTarget == Other.AltSource {
			return Prism(tryGet: { self.tryGet($0).flatMap(other.tryGet) }, inject: self.inject • other.inject)
	}

	/// Attempts to run a value of type `S` along both parts of the Prism.  If 
	/// `.None` is encountered along the getter returns `.None`, else returns 
	/// `.Some` containing the final value.
	public func tryModify(_ s : Source, _ f : @escaping (Target) -> AltTarget) -> AltSource? {
		return tryGet(s).map(self.inject • f)
	}
}

public func • <Left : PrismType, Right : PrismType>
	(l : Left, r : Right) -> Prism<Left.Source, Left.AltSource, Right.Target, Right.AltTarget> where
	Left.Target == Right.Source,
	Left.AltTarget == Right.AltSource {
		return l.compose(r)
}
