//
//  FormatFlag.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-17.
//

public struct FormatFlag: OptionSet {
	public let rawValue: Int
	
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}
	
	/// If not, padding is space char
	public static let zero = FormatFlag(rawValue: 1 << 0)
	/// If not, no flag implied
	public static let minus = FormatFlag(rawValue: 1 << 1)
	/// If not, no flag implied, overrides space
	public static let plus = FormatFlag(rawValue: 1 << 2)
	/// If not, no flag implied
	public static let space = FormatFlag(rawValue: 1 << 3)
	/// Using config dict
	public static let externalSpec = FormatFlag(rawValue: 1 << 4)
	/// Explicitly mark the specs we can localize
	public static let localizable = FormatFlag(rawValue: 1 << 5)
	/// Using entity marker
	public static let entityMarker = FormatFlag(rawValue: 1 << 6)
}
