//
//  Monomorphic.swift
//  Focus
//
//  Created by Robert Widmann on 8/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public typealias SimpleLens<S, A> = Lens<S, S, A, A>
public typealias SimpleIso<S, A> = Iso<S, S, A, A>
public typealias SimplePrism<S, A> = Prism<S, S, A, A>
public typealias SimpleSetter<S, A> = Setter<S, S, A, A>
