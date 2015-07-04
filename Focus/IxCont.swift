//
//  IxCont.swift
//  swiftz
//
//  Created by Alexander Ronald Altman on 6/10/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// `IxCont` is the Continuation Monad indexed by a result type `R`, an immediate output type `O` 
/// and a value `A`.
public struct IxCont<R, O, A> {
    /// Lowers an `IxCont` to an indexed continuation function.
	public let run : (A -> O) -> R

    /// Lifts an indexed continuation function into an `IxCont`.
	public init(_ run : (A -> O) -> R) {
		self.run = run
	}

    /// Applies a function that transforms the input value of the continuation function.
	public func map<B>(f : A -> B) -> IxCont<R, O, B> {
		return f <^> self
	}

    /// Applies a function that transforms the final output value of the continuation function.
	public func imap<S>(f : R -> S) -> IxCont<S, O, A> {
		return f <^^> self
	}

    /// Applies a function that transforms the immediate output value of the continuation function.
	public func contramap<N>(f : N -> O) -> IxCont<R, N, A> {
		return f <!> self
	}

    /// Composes two continuation functions by applying the final result of the second to the
    /// immediate value of the first then running both continuations in series.
	public func ap<E, B>(f : IxCont<E, R, A -> B>) -> IxCont<E, O, B> {
		return f <*> self
	}

    /// Fits the receiver together with a second continuation and runs them in series.
	public func flatMap<E, B>(f : A -> IxCont<O, E, B>) -> IxCont<R, E, B> {
		return self >>- f
	}
}

public func run<R, O>(a : IxCont<R, O, O>) -> R {
	return a.run(identity)
}

public func pure<R, A>(x : A) -> IxCont<R, R, A> {
	return IxCont { $0(x) }
}

public func <^> <R, O, A, B>(f : A -> B, a: IxCont<R, O, A>) -> IxCont<R, O, B> {
	return IxCont { k in a.run { k(f($0)) } }
}

public func <^^> <R, S, O, A>(f : R -> S, a: IxCont<R, O, A>) -> IxCont<S, O, A> {
	return IxCont { f(a.run($0)) }
}

public func <!> <R, N, O, A>(f : N -> O, a: IxCont<R, O, A>) -> IxCont<R, N, A> {
	return IxCont { k in a.run { f(k($0)) } }
}

public func <*> <R, I, O, A, B>(f : IxCont<R, I, A -> B>, a: IxCont<I, O, A>) -> IxCont<R, O, B> {
	return IxCont { k in f.run { g in a.run { k(g($0)) } } }
}

public func >>- <R, I, O, A, B>(a : IxCont<R, I, A>, f: A -> IxCont<I, O, B>) -> IxCont<R, O, B> {
	return IxCont { k in a.run { f($0).run(k) } }
}

public func join<R, I, O, A>(a : IxCont<R, I, IxCont<I, O, A>>) -> IxCont<R, O, A> {
	return IxCont { k in a.run { $0.run(k) } }
}

public func shift<R, I, J, O, A>(f : (A -> IxCont<I, I, O>) -> IxCont<R, J, J>) -> IxCont<R, O, A> {
	return IxCont { k in run(f { pure(k($0)) }) }
}

public func reset<R, O, A>(a : IxCont<A, O, O>) -> IxCont<R, R, A> {
	return pure(run(a))
}

public func callCC<R, O, A, B>(f : (A -> IxCont<O, O, B>) -> IxCont<R, O, A>) -> IxCont<R, O, A> {
	return IxCont { k in (f { x in IxCont { _ in k(x) } }).run(k) }
}
