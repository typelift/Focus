//
//  Lens.swift
//  swiftz
//
//  Created by Maxwell Swadling on 8/06/2014.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// A `Lens` (or Functional Reference) describes a way of focusing on the parts 
/// of a structure, composing with other lenses to focus deeper into a 
/// structure, and returning new structures with parts modified.  In this way, a
/// `Lens` can be thought of as a reference to a subpart of a structure.
///
/// In practice, a `Lens` is used with Product structures like tuples, classes, 
/// and structs. If a less-powerful form of `Lens` is needed, consider using a 
/// `SimpleLens` instead.
///
/// A Lens, in its simplest form, can also be seen as a pair of functions:
/// 
/// - `get` to retrieve a focused part of the structure.
/// - `set` to replace focused parts and yield a new modified structure.
///
/// A well-behaved `Lens` should obey the following laws:
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
/// - parameter S: The structure to be focused.
/// - parameter T: The modified form of the structure.
/// - parameter A: The result of retrieving the focused subpart.
/// - parameter B: The modification to make to the original structure.
public struct Lens<S, T, A, B> : LensType {
	public typealias Source = S
	public typealias Target = A
	public typealias AltSource = T
	public typealias AltTarget = B

	/// Gets the Indexed Costate Comonad Coalgebroid underlying the receiver.
	private let _run : S -> IxStore<A, B, T>

	/// Runs the lens on a structure to retrieve the underlying Indexed Costate 
	/// Comonad Coalgebroid.
	public func run(v : S) -> IxStore<A, B, T> {
		return _run(v)
	}

	/// Produces a lens from an Indexed Costate Comonad Coalgebroid.
	public init(_ f : S -> IxStore<A, B, T>) {
		_run = f
	}

	/// Creates a lens from a getter/setter pair.
	public init(get : S -> A, set : (S, B) -> T) {
		self.init({ v in IxStore(get(v)) { set(v, $0) } })
	}

	/// Creates a lens that transforms set values by a given function before 
	/// they are returned.
	public init(get : S -> A, modify : (S, A -> B) -> T) {
		self.init(get: get, set: { v, x in modify(v) { _ in x } })
	}
}

/// Captures the essential structure of a Lens.
public protocol LensType : OpticFamilyType {
	/// Gets the Indexed Costate Comonad Coalgebroid underlying the receiver.
	func run(_ : Source) -> IxStore<Target, AltTarget, AltSource>
}

extension Lens {
	public init<Other : LensType where
		S == Other.Source, A == Other.Target, T == Other.AltSource, B == Other.AltTarget>
		(_ other : Other)
	{
		self.init(other.run)
	}
}

extension Lens : SetterType {
	public func over(f: A -> B) -> S -> T {
		return { s in self.modify(s, f) }
	}
}

extension LensType {
	/// Runs the getter on a given structure.
	public func get(v : Source) -> Target {
		return run(v).pos
	}

	/// Runs the setter on a given structure and value to yield a new structure.
	public func set(v : Source, _ x : AltTarget) -> AltSource {
		return run(v).peek(x)
	}

	/// Transform the value of the retrieved field by a function.
	public func modify(v : Source, _ f : Target -> AltTarget) -> AltSource {
		let q = run(v)
		return q.peek(f(q.pos))
	}

	/// Composes a `Lens` with the receiver.
	public func compose<Other : LensType where
		Self.Target == Other.Source,
		Self.AltTarget == Other.AltSource>
		(other : Other) -> Lens<Source, AltSource, Other.Target, Other.AltTarget> {
			return Lens { v in
				let q1 = self.run(v)
				let q2 = other.run(q1.pos)
				return IxStore(q2.pos) { q1.peek(q2.peek($0)) }
			}
	}

	/// Uses the receiver to focus in on a State Monad.
	public func zoom<X>(a : IxState<Target, AltTarget, X>) -> IxState<Source, AltSource, X> {
		return IxState { s1 in
			let q = self.run(s1)
			let (x, s2) = a.run(q.pos)
			return (x, q.peek(s2))
		}
	}

	/// Creates a `Lens` that focuses on two structures.
	public func split<Other : LensType>(right : Other) -> Lens<
		(Source, Other.Source), (AltSource, Other.AltSource),
		(Target, Other.Target), (AltTarget, Other.AltTarget)>
	{
		return Lens { (vl, vr) in
			let q1 = self.run(vl)
			let q2 = right.run(vr)
			return IxStore((q1.pos, q2.pos)) { (l, r) in (q1.peek(l), q2.peek(r)) }
		}
	}

	/// Creates a `Lens` that sends its input structure to both Lenses to focus 
	/// on distinct subparts.
	public func fanout<Other : LensType
		where Source == Other.Source, AltTarget == Other.AltTarget>
		(right : Other) -> Lens<Source, (AltSource, Other.AltSource), (Target, Other.Target), AltTarget>
	{
		return Lens { s in
			let q1 = self.run(s)
			let q2 = right.run(s)
			return IxStore((q1.pos, q2.pos)) { (q1.peek($0), q2.peek($0)) }
		}
	}
}

/// Composes two lenses to yield a "more focused" lens.
///
/// `Lens` composition occurs like property notation, in that more specific 
/// lenses come last rather than first as they would under traditional function 
/// composition.
public func • <Left : LensType, Right : LensType where
	Left.Target == Right.Source,
	Left.AltTarget == Right.AltSource>
	(l : Left, r : Right) -> Lens<Left.Source, Left.AltSource, Right.Target, Right.AltTarget> {
		return l.compose(r)
}
