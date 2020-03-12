//
//  String+Specs.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-17.
//

import Foundation

public extension String {
	func formatSpecifiers() throws -> [Spec] {
		return try findFormatSpecifiersInString(formatString: self)
	}
	
	subscript(spec: Spec) -> Substring {
		let end = self.index(spec.location, offsetBy: spec.length)
		return self[spec.location..<end]
	}
}

private func findFormatSpecifiersInString(formatString: String) throws -> [Spec] {
	var specs: [Spec] = []
	var formatIndex = formatString.startIndex
	while var newFormatIndex = formatString[formatIndex...].firstIndex(of: "%") {
		let startIndex = newFormatIndex
		var spec = try Spec(formatString: formatString, formatIndex: &newFormatIndex)
		if spec.type != .literal {
			let length = formatString.distance(from: startIndex, to: newFormatIndex)
			spec.length = length
			specs.append(spec)
		}
		formatIndex = newFormatIndex
	}
	return specs
}
