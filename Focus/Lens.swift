//
//  Lens.swift
//  swiftz
//
//  Created by Maxwell Swadling on 8/06/2014.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// A Lens (or Functional Reference) describes a way of focusing on the parts of a structure,
/// composing with other lenses to focus deeper into a structure, and returning new structures with 
/// parts modified.  In this way, a Lens can be thought of as a reference to a subpart of a 
/// structure.
///
/// A well-behaved Lens should obey the following laws:
///
/// - You get back what you put in:
///
///     l.get(l.set(s, b)) == b
///
/// - Putting back what you got doesn't change anything:
///
///     l.set(s, l.get(a)) == a
///
/// - Setting twice is the same as setting once:
///
///     l.set(l.set(s, a), b) == l.set(s, b)
///
/// :param: S The source of the Lens
/// :param: T The modified source of the Lens
/// :param: A The target of the Lens
/// :param: B The modified target the Lens
public struct Lens<S, T, A, B> {
	/// Gets the Indexed Costate Comonad Coalgebroid underlying the receiver.
	public let run : S -> IxStore<A, B, T>

	public init(_ run : S -> IxStore<A, B, T>) {
		self.run = run
	}

	/// Creates a lens from a getter/setter pair.
	public init(get : S -> A, set : (S, B) -> T) {
		self.init({ v in IxStore(get(v)) { set(v, $0) } })
	}

	/// Creates a lens that transforms set values by a given function before they are returned.
	public init(get : S -> A, modify : (S, A -> B) -> T) {
		self.init(get: get, set: { v, x in modify(v) { _ in x } })
	}

	/// Composes a `Lens` with the receiver.
	public func compose<I, J>(l2 : Lens<A, B, I, J>) -> Lens<S, T, I, J> {
		return self • l2
	}
	
	/// Runs the getter on a given structure.
	public func get(v : S) -> A {
		return run(v).pos
	}

	/// Runs the setter on a given structure and value to yield a new structure.
	public func set(v : S, _ x : B) -> T {
		return run(v).peek(x)
	}

	/// Transform the value of the retrieved field by a function.
	public func modify(v : S, _ f : A -> B) -> T {
		let q = run(v)
		return q.peek(f(q.pos))
	}

	/// Uses the receiver to focus in on a State Monad.
	public func zoom<X>(a : IxState<A, B, X>) -> IxState<S, T, X> {
		return IxState { s1 in
			let q = self.run(s1)
			let (x, s2) = a.run(q.pos)
			return (x, q.peek(s2))
		}
	}
	
	/// Creates a Lens that focuses on two structures.
	public func split<S_, T_, A_, B_>(right : Lens<S_, T_, A_, B_>) -> Lens<(S, S_), (T, T_), (A, A_), (B, B_)> {
		return Lens<(S, S_), (T, T_), (A, A_), (B, B_)> { (vl, vr) in
			let q1 = self.run(vl)
			let q2 = right.run(vr)
			return IxStore((q1.pos, q2.pos)) { (l, r) in (q1.peek(l), q2.peek(r)) }
		}
	}
	
	/// Creates a Lens that sends its input structure to both Lenses to focus on distinct subparts.
	public func fanout<A_, T_>(right : Lens<S, T_, A_, B>) -> Lens<S, (T, T_), (A, A_), B> {
		return Lens<S, (T, T_), (A, A_), B> { s in
			let q1 = self.run(s)
			let q2 = right.run(s)
			return IxStore((q1.pos, q2.pos)) { (q1.peek($0), q2.peek($0)) }
		}
	}
}

public func • <S, T, I, J, A, B>(l1 : Lens<S, T, I, J>, l2 : Lens<I, J, A, B>) -> Lens<S, T, A, B> {
	return Lens { v in
		let q1 = l1.run(v)
		let q2 = l2.run(q1.pos)
		return IxStore(q2.pos) { q1.peek(q2.peek($0)) }
	}
}
