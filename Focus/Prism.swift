//
//  Prism.swift
//  swiftz
//
//  Created by Alexander Ronald Altman on 7/22/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// A Prism is an `Iso` where one of the functions is partial.
public struct Prism<S, T, A, B> {
    ///
	public let tryGet : S -> A?
	public let inject : B -> T

	public init(tryGet : S -> A?, inject : B -> T) {
		self.tryGet = tryGet
		self.inject = inject
	}

    /// Composes a `Prism` with the receiver.
    public func compose<I, J>(i2 : Prism<A, B, I, J>) -> Prism<S, T, I, J> {
        return self • i2
    }
    
	public func tryModify(s : S, _ f : A -> B) -> T? {
		return tryGet(s).map(self.inject • f)
	}
}

public func • <S, T, I, J, A, B>(p1 : Prism<S, T, I, J>, p2 : Prism<I, J, A, B>) -> Prism<S, T, A, B> {
	return Prism(tryGet: { p1.tryGet($0).flatMap(p2.tryGet) }, inject: p1.inject • p2.inject)
}

public func _Some<A, B>() -> Prism<A?, B?, A, B> {
    return Prism(tryGet: identity, inject: Optional<B>.Some)
}

public func _None<A, B>() -> Prism<A?, B?, A, B> {
    return Prism(tryGet: { _ in .None }, inject: { _ in .None })
}
