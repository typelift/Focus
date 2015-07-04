//
//  Operator.swift
//  Focus
//
//  Created by Robert Widmann on 7/2/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

/// Compose | Applies one function to the result of another function to produce a third function.
infix operator • {
    associativity right
    precedence 190
}

/// MARK: Control.*

/// Fmap | Maps a function over the value encapsulated by a functor.
infix operator <^> {
    associativity left
    precedence 140
}

/// Imap | Maps covariantly over the index of a right-leaning bifunctor.
infix operator <^^> {
    associativity left
    precedence 140
}

/// Contramap | Contravariantly maps a function over the value encapsulated by a functor.
infix operator <!> {
    associativity left
    precedence 140
}

/// Ap | Applies a function encapsulated by a functor to the value encapsulated by another functor.
infix operator <*> {
    associativity left
    precedence 140
}

/// Bind | Sequences and composes two monadic actions by passing the value inside the monad on the
/// left to a function on the right yielding a new monad.
infix operator >>- {
    associativity left
    precedence 110
}

/// Extend | Duplicates the surrounding context and computes a value from it while remaining in the
/// original context.
infix operator ->> {
    associativity left
    precedence 110
}

/// The identity function.
internal func identity<A>(a : A) -> A {
    return a
}

/// Compose | Applies one function to the result of another function to produce a third function.
///
///     f : B -> C
///     g : A -> B
///     (f • g)(x) === f(g(x)) : A -> B -> C
internal func • <A, B, C>(f : B -> C, g: A -> B) -> A -> C {
    return { (a : A) -> C in
        return f(g(a))
    }
}
