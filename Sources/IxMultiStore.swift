//
//  IxMultiStore.swift
//  swiftz
//
//  Created by Alexander Ronald Altman on 8/4/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// The Store Comonad Transformer indexed by a position type `O` and the 
/// `ArrayZipper` Comonad.
public struct IxMultiStore<O, I, A> {
	/// The current position of the receiver.
	let pos : O

	/// Retrieves a zipper that focuses on functions that retrieve values at 
	/// index I.
	let set : ArrayZipper<(I) -> A>

	public init(_ pos: O, _ set: ArrayZipper<(I) -> A>) {
		self.pos = pos
		self.set = set
	}

	/// Applies a function to the retrieval of values.
	public func map<B>(_ f : @escaping (A) -> B) -> IxMultiStore<O, I, B> {
		return f <^> self
	}

	/// Applies a function to the position indexes that can be focused on by the
	/// underlying zipper.
	public func imap<P>(_ f : @escaping (O) -> P) -> IxMultiStore<P, I, A> {
		return f <^^> self
	}

	/// Applies a function to the retrieval indexes of the underlying zipper.
	public func contramap<H>(_ f : @escaping (H) -> I) -> IxMultiStore<O, H, A> {
		return f <!> self
	}

	/// Returns an `IxStore` that retrieves an `IxStore` for every index in the 
	/// receiver.
	public func duplicate<J>() -> IxMultiStore<O, J, IxMultiStore<J, I, A>> {
		return IxMultiStore<O, J, IxMultiStore<J, I, A>>(pos, set ->> { g in { IxMultiStore<J, I, A>($0, g) } })
	}

	/// Extends the context of the store with a function that retrieves values 
	/// from another store indexed by a different position.
	public func extend<E, B>(_ f : @escaping (IxMultiStore<E, I, A>) -> B) -> IxMultiStore<O, E, B> {
		return self ->> f
	}

	/// Extracts a zipper that focuses on all values at a given index.
	public func put(_ x : I) -> ArrayZipper<A> {
		return { $0(x) } <^> set
	}

	/// Extracts a zipper that focuses on all values at an index given by 
	/// applying a function to the receiver's position index.
	public func puts(_ f : (O) -> I) -> ArrayZipper<A> {
		return put(f(pos))
	}

	/// Extracts the first focused value from the store at a given index.
	public func peek(_ x : I) -> A {
		return put(x).extract()
	}

	/// Extracts the first focused value from the store at an index given by 
	/// applying a function to the receiver's position index.
	public func peeks(_ f : (O) -> I) -> A {
		return peek(f(pos))
	}

	/// Returns a new `IxMultiStore` with its position index set to the given 
	/// value.
	public func seek<P>(_ x : P) -> IxMultiStore<P, I, A> {
		return IxMultiStore<P, I, A>(x, set)
	}

	/// Returns a new `IxMultiStore` with its position index set to the result 
	/// of applying the given function to the current position index.
	public func seeks<P>(_ f : (O) -> P) -> IxMultiStore<P, I, A> {
		return IxMultiStore<P, I, A>(f(pos), set)
	}
}

/// Extracts a value from the Multi Store.
public func extract<I, A>(_ a : IxMultiStore<I, I, A>) -> A {
	return a.set.extract()(a.pos)
}

/// Lowers a Multi Store into an `ArrayZipper` of all values at the current 
/// position.
public func lower<I, A>(_ a : IxMultiStore<I, I, A>) -> ArrayZipper<A> {
	return { $0(a.pos) } <^> a.set
}

public func <^> <O, I, A, B>(f : @escaping (A) -> B, a : IxMultiStore<O, I, A>) -> IxMultiStore<O, I, B> {
	return IxMultiStore(a.pos, { g in { f(g($0)) } } <^> a.set)
}

public func <^^> <O, P, I, A>(f : (O) -> P, a : IxMultiStore<O, I, A>) -> IxMultiStore<P, I, A> {
	return IxMultiStore(f(a.pos), a.set)
}

public func <!> <O, H, I, A>(f : @escaping (H) -> I, a : IxMultiStore<O, I, A>) -> IxMultiStore<O, H, A> {
	return IxMultiStore(a.pos, { $0 • f } <^> a.set)
}

public func ->> <O, J, I, A, B>(a : IxMultiStore<O, I, A>, f : @escaping (IxMultiStore<J, I, A>) -> B) -> IxMultiStore<O, J, B> {
	return IxMultiStore(a.pos, a.set ->> { g in { f(IxMultiStore($0, g)) } })
}
