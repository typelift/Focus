//
//  Protocols.swift
//  Focus
//
//  Created by Alexander Ronald Altman on 7/13/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

/// The shared supertype of all optics.
///
/// N.B.: Right now, this exists solely to standardize the four
/// `typealias`es that the other `protocol`s all use, but, in future
/// releases, `extension`s of it may provide some optic-generic operators.
public protocol OpticFamilyType {
	typealias Source
	typealias Target
	typealias AltSource
	typealias AltTarget
}
