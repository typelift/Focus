//
//  Lens.swift
//  swiftz
//
//  Created by Ryan Peck on 3/18/16.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// A `Setter` describes a way of applying a transformation to a
/// subpart of a structure. Composed with other optics, they can 
/// be used to modify multiple parts of a larger structure.
///
/// If a less-powerful form of `Setter` is needed, consider using a
/// `SimpleSetter` instead.
///
/// - parameter S: The structure to be modified
/// - parameter T: The modified form of the structure.
/// - parameter A: The existing subpart to be modified.
/// - parameter B: The result of modifying the subpart.
public struct Setter<S, T, A, B> : SetterType {
    public typealias Source = S
    public typealias Target = A
    public typealias AltSource = T
    public typealias AltTarget = B

    private let _over : (@escaping (A) -> B) -> (S) -> T

    public init(over : @escaping (@escaping (A) -> B) -> (S) -> T) {
        self._over = over
    }

    public func over(_ f : @escaping (A) -> B) -> (S) -> T {
        return _over(f)
    }
}

public protocol SetterType : OpticFamilyType {
    func over(_ f : @escaping (Target) -> AltTarget) -> (Source) -> AltSource
}

extension SetterType {
    /// Composes a `Setter` with the receiver.
    public func compose<Other : SetterType>
        (_ other : Other) -> Setter<Source, AltSource, Other.Target, Other.AltTarget> where
        Other.Source == Target,
        Other.AltSource == AltTarget {
			return Setter { f in self.over(other.over(f)) }
    }
}

public func • <Left : SetterType, Right : SetterType>
    (left : Left, right : Right) -> Setter<Right.Source, Right.AltSource, Left.Target, Left.AltTarget> where
    Left.Source == Right.Target,
    Left.AltSource == Right.AltTarget {
        return right.compose(left)
}
