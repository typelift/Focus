import XCTest

@testable import FocusTests

#if !os(macOS)
XCTMain([
  IsoSpec.allTests,
  LensSpec.allTests,
  PartySpec.allTests,
  PrismSpec.allTests,
  SetterSpec.allTests,
  SimpleIsoSpec.allTests,
  SimpleLensSpec.allTests,
  SimplePrismSpec.allTests,
  SimpleSetterSpec.allTests,
])
#endif
