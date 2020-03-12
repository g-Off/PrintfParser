//
//  Literal.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-17.
//

public enum Literal {
	case unknown
	case literal
	case long
	case double
	case pointer
	/// handled specially; this is the general object type
	case cf
	/// handled specially
	case unichars
	/// handled specially
	case chars
	/// handled specially
	case pascalChars
	/// handled specially
	case singleUnichar
	/// special case for %n
	case dummyPointer
}

extension Literal: Equatable {}
