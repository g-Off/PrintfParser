//
//  Size.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-17.
//

public enum Size {
	case defaultSize
	case size1
	case size2
	case size4
	case size8
	case size16
	
	public static let long = Self.size8
	public static let pointer = Self.size8
}

extension Size: Equatable {}
