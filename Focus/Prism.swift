//
//  Prism.swift
//  swiftz
//
//  Created by Alexander Ronald Altman on 7/22/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// A Prism is an `Iso` where one of the functions is partial.
///
/// - parameter S: The source of the Prism
/// - parameter T: The modified source of the Prism
/// - parameter A: The possible target of the Prism
/// - parameter B: The modified target the Prism
public struct Prism<S, T, A, B> : PrismType {
	typealias Source = S
	typealias Target = A
	typealias AltSource = T
	typealias AltTarget = B

	private let _tryGet : S -> A?
	private let _inject : B -> T

	public init(tryGet f : S -> A?, inject g : B -> T) {
		_tryGet = f
		_inject = g
	}

	public func tryGet(v : Source) -> Target? {
		return _tryGet(v)
	}

	public func inject(x : AltTarget) -> AltSource {
		return _inject(x)
	}
}

public protocol PrismType : OpticFamilyType {
	func tryGet(_ : Source) -> Target?
	func inject(_ : AltTarget) -> AltSource
}

extension Prism {
	public init<Other : PrismType where
		S == Other.Source, A == Other.Target, T == Other.AltSource, B == Other.AltTarget>
		(_ other : Other)
	{
		self.init(tryGet: other.tryGet, inject: other.inject)
	}
}

/// Provides a Prism for tweaking values inside `.Some`.
public func _Some<A, B>() -> Prism<A?, B?, A, B> {
	return Prism(tryGet: identity, inject: Optional<B>.Some)
}

/// Provides a Prism for traversing `.None`.
public func _None<A, B>() -> Prism<A?, B?, A, B> {
	return Prism(tryGet: { _ in .None }, inject: { _ in .None })
}

extension PrismType {
	/// Composes a `Prism` with the receiver.
	public func compose<Other : PrismType where
		Self.Target == Other.Source,
		Self.AltTarget == Other.AltSource>
		(other : Other) -> Prism<Source, AltSource, Other.Target, Other.AltTarget> {
		return Prism(tryGet: { self.tryGet($0).flatMap(other.tryGet) }, inject: self.inject • other.inject)
	}

	/// Attempts to run a value of type `S` along both parts of the Prism.  If `.None` is
	/// encountered along the getter returns `.None`, else returns `.Some` containing the final
	/// value.
	public func tryModify(s : Source, _ f : Target -> AltTarget) -> AltSource? {
		return tryGet(s).map(self.inject • f)
	}
}

public func • <Left : PrismType, Right : PrismType where
	Left.Target == Right.Source,
	Left.AltTarget == Right.AltSource>
	(l : Left, r : Right) -> Prism<Left.Source, Left.AltSource, Right.Target, Right.AltTarget> {
	return l.compose(r)
}
