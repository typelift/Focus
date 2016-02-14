//
//  IxStore.swift
//  swiftz
//
//  Created by Alexander Ronald Altman on 6/12/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// An `IxStore` models a store of variables of type `A` each at an index of 
/// type `I`.  Unlike the Costate Comonad, `IxStore`'s position is indexed by a 
/// type `O`.
///
/// N.B.:  In the indexed store comonad transformer, set, put, and peek are all
/// distinct, as are puts and peeks.  The lack of distinction here is due to the
/// lack of transformer nature; as soon as we get transformers, that will change.
public struct IxStore<O, I, A> {
	/// The current position of the receiver.
	let pos : O

	/// Retrieves the value at index `I`.
	let set : I -> A

	public init(_ pos: O, _ set: I -> A) {
		self.pos = pos
		self.set = set
	}

	/// Applies a function to the retrieval of values.
	public func map<B>(f : A -> B) -> IxStore<O, I, B> {
		return f <^> self
	}

	/// Applies a function to the position index.
	public func imap<P>(f : O -> P) -> IxStore<P, I, A> {
		return f <^^> self
	}

	/// Applies a function to the retrieval index.
	public func contramap<H>(f : H -> I) -> IxStore<O, H, A> {
		return f <!> self
	}

	/// Returns an `IxStore` that retrieves an `IxStore` for every index in the receiver.
	public func duplicate<J>() -> IxStore<O, J, IxStore<J, I, A>> {
		return IxStore<O, J, IxStore<J, I, A>>(pos) { IxStore<J, I, A>($0, self.set) }
	}

	/// Extends the context of the store with a function that retrieves values from another store
	/// indexed by a different position.
	public func extend<E, B>(f : IxStore<E, I, A> -> B) -> IxStore<O, E, B> {
		return self ->> f
	}

	/// Extracts a value from the store at a given index.
	public func peek(x : I) -> A {
		return set(x)
	}

	/// Extracts a value from the store at an index given by applying a function to the receiver's
	/// position index.
	public func peeks(f : O -> I) -> A {
		return set(f(pos))
	}

	/// Extracts a value from the store at a given index.
	///
	/// With a proper Monad Transformer this function would use a Comonadic context to extract a
	/// value.
	public func put(x : I) -> A {
		return set(x)
	}

	/// Extracts a value from the store at an index given by applying a function to the receiver's
	/// position index.
	///
	/// With a proper Monad Transformer this function would use a Comonadic context to extract a
	/// value.
	public func puts(f : O -> I) -> A {
		return set(f(pos))
	}

	/// Returns a new `IxStore` with its position index set to the given value.
	public func seek<P>(x : P) -> IxStore<P, I, A> {
		return IxStore<P, I, A>(x, set)
	}

	/// Returns a new `IxStore` with its position index set to the result of applying the given
	/// function to the current position index.
	public func seeks<P>(f : O -> P) -> IxStore<P, I, A> {
		return IxStore<P, I, A>(f(pos), set)
	}
}

/// The trivial `IxStore` always retrieves the same value at all indexes.
public func trivial<A>(x : A) -> IxStore<A, A, A> {
	return IxStore(x, identity)
}

/// Extracts a value from the receiver at its position index.
public func extract<I, A>(a : IxStore<I, I, A>) -> A {
	return a.set(a.pos)
}

public func <^> <O, I, A, B>(f : A -> B, a : IxStore<O, I, A>) -> IxStore<O, I, B> {
	return IxStore(a.pos) { f(a.set($0)) }
}

public func <^^> <O, P, I, A>(f : O -> P, a : IxStore<O, I, A>) -> IxStore<P, I, A> {
	return IxStore(f(a.pos), a.set)
}

public func <!> <O, H, I, A>(f : H -> I, a : IxStore<O, I, A>) -> IxStore<O, H, A> {
	return IxStore(a.pos) { a.set(f($0)) }
}

public func ->> <O, J, I, A, B>(a : IxStore<O, I, A>, f : IxStore<J, I, A> -> B) -> IxStore<O, J, B> {
	return IxStore(a.pos) { f(IxStore($0, a.set)) }
}
