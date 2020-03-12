//
//  Spec.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-17.
//

public struct Spec {
	public enum Arg: Equatable {
		case value(Int)
		case index(Int8)
	}
	
	public var size: Size = .defaultSize
	public var type: Literal = .unknown
	public var location: String.Index
	public var length: String.IndexDistance = 0
	public var flags: FormatFlag = []
	
	/// The position of the argument in the argument list.
	public var mainArgNum: Int8?
	
	fileprivate var precArgNum: Int8 = -1
	fileprivate var precArg: Int = -1

	fileprivate var widthArg: Int = -1
	fileprivate var widthArgNum: Int8 = -1
	
	public var precision: Arg? {
		if precArgNum > -1 {
			return .index(precArgNum)
		} else if precArg > -1 {
			return .value(precArg)
		} else {
			return nil
		}
	}
	
	public var width: Arg? {
		if widthArgNum > -1 {
			return .index(widthArgNum)
		} else if widthArg > -1 {
			return .value(widthArg)
		} else {
			return nil
		}
	}
	
	/// Only set for localizable numeric quantities
	public var numericStyle: Style?
	
	public var configKey: String?
}

extension Spec: Equatable {}
//extension Spec: CustomDebugStringConvertible {
//	public var debugDescription: String {
//		"size: \(size)"
//	}
//}

extension Spec {
	init(formatString: String, formatIndex: inout String.Index) throws {
		self = try parseFormatSpec(formatString: formatString, formatIndex: &formatIndex)
	}
}

private extension String {
	/// Returns the character at the given index and advances the index by one.
	/// - Parameter index: The current index
	/// - Returns: The character at the given index
	func character(advancing index: inout String.Index) -> Character {
		defer {
			index = self.index(after: index)
		}
		return self[index]
	}
}

private func parseFormatSpec(formatString: String, formatIndex: inout String.Index) throws -> Spec {
	precondition(formatString[formatIndex] == "%", "formatString[formatIndex] must be a '%'")
	
	var spec = Spec(location: formatIndex)
	formatIndex = formatString.index(after: formatIndex) // Skip `%`
	
	guard formatIndex < formatString.endIndex else {
		throw FormatError.invalid
	}
	
	var seenDot = false
	var seenSharp = false
	var seenOpenBracket = false
	var validBracketSequence = false
	
	var keyLength: String.IndexDistance = 0
	var keyIndex: String.Index?
	
	while formatIndex < formatString.endIndex {
		var character = formatString.character(advancing: &formatIndex)
		
		if let index = keyIndex {
			if (character < "0") ||
				((character > "9") && (character < "A")) ||
				((character > "Z") && (character < "a") && (character != "_")) ||
				(character > "z") {
				
				if character == "]" {
					if seenOpenBracket {
						validBracketSequence = true
						keyLength = formatString.distance(from: index, to: formatIndex) - 1
					}
				} else if character == "@" {
					if validBracketSequence {
						spec.flags.formUnion(.entityMarker)
					} else {
						keyLength = formatString.distance(from: index, to: formatIndex) - 1
					}
					spec.flags.formUnion(.externalSpec)
					spec.type = .cf
					spec.size = .pointer
					
					if keyLength > 0 {
						spec.configKey = String(formatString[index..<formatString.index(index, offsetBy: keyLength)])
					}
					
					return spec
				} else {
					keyIndex = nil
				}
			}
			continue
		}
		
		var repeatSwitch = false
		repeat {
			repeatSwitch = false // reset the repeat flag
			
			switch character {
			case "#": // ignored for now
				seenSharp = true
			case "[":
				if !seenOpenBracket { // We can only have one
					seenOpenBracket = true
					keyIndex = formatIndex
				}
			case " ": // 0x20 ??
				if !spec.flags.contains(.plus) {
					spec.flags.formUnion(.space)
				}
			case "-":
				spec.flags.formUnion(.minus)
				spec.flags.subtract(.zero) // remove zero flag
			case "+":
				spec.flags.formUnion(.plus)
				spec.flags.subtract(.space) // remove space flag
			case "0":
				if seenDot { // after we see '.' and then we see '0', it is 0 precision. We should not see '.' after '0' if '0' is the zero padding flag
					spec.precArg = 0
					break
				}
				if !spec.flags.contains(.minus) {
					spec.flags.formUnion(.zero)
				}
			case "h":
				if formatIndex < formatString.endIndex {
					// fetch next character, don't increment fmtIdx
					character = formatString[formatIndex]
					if character == "h" { // 'hh' for char, like 'c'
						formatIndex = formatString.index(after: formatIndex)
						spec.size = .size1
						break
					}
				}
				spec.size = .size2
			case "l":
				if formatIndex < formatString.endIndex {
					// fetch next character, don't increment fmtIdx
					character = formatString[formatIndex]
					if character == "l" { // 'll' for long long, like 'q'
						formatIndex = formatString.index(after: formatIndex)
						spec.size = .size8
						break
					}
				}
				spec.size = .long
			case "L":
				spec.size = .size16
			case "q":
				spec.size = .size8
			case "t", "z":
				spec.size = .long
			case "j":
				spec.size = .size8
			case "c":
				spec.type = .long
				spec.size = .size1
				return spec
			case "D", "d", "i", "U", "u":
				spec.flags.formUnion(.localizable)
				if character == "u" || character == "U" {
					spec.numericStyle = .unsigned
				} else {
					spec.numericStyle = .decimal
				}
				fallthrough
			case "O", "o", "X", "x":
				spec.type = .long
				// Seems like if spec.size == 0, we should spec.size = .size4. However, 0 is handled correctly.
				return spec
			case "F", "f", "G", "g", "E", "e":
				// TODO
				spec.flags.formUnion(.localizable)
				let lowercased = character.lowercased()
				if lowercased == "e" || lowercased == "g" {
					spec.numericStyle = .scientific
				} else if lowercased == "f" || lowercased == "g" {
					spec.numericStyle = .decimal
				}
				if seenDot && spec.precArg == -1 && spec.precArgNum == -1 { // for the cases that we have '.' but no precision followed, not even '*'
					spec.precArg = 0
				}
				fallthrough
			case "A", "a":
				spec.type = .double
				if spec.size != .size16 {
					spec.size = .size8
				}
				return spec
			case "n": // %n is not handled correctly; for Leopard or newer apps, we disable it further
				// spec.type = true ? .dummyPointer : .pointer // This is how it's handled in CF, but produces a warning about always evaluating to true, so hardcoding that version below
				spec.type = .dummyPointer
				spec.size = .pointer
				return spec
			case "p":
				spec.type = .pointer
				spec.size = .pointer
				return spec
			case "s":
				spec.type = .chars
				spec.size = .pointer
				return spec
			case "S":
				spec.type = .unichars
				spec.size = .pointer
			case "C":
				spec.type = .singleUnichar
				spec.size = .size2
			case "P":
				spec.type = .pascalChars
				spec.size = .pointer
			case "@":
				if seenSharp {
					seenSharp = false
					keyIndex = formatIndex
				} else {
					spec.type = .cf
					spec.size = .pointer
					return spec
				}
			case "1"..."9":
				var number: Int64 = 0
				
				repeat {
					var overflow: Bool = false
					(number, overflow) = number.multipliedReportingOverflow(by: 10)
					if overflow {
						throw FormatError.overflow
					}
					let wholeNumber = Int64(character.wholeNumberValue!)
					(number, overflow) = number.addingReportingOverflow(wholeNumber)
					if overflow {
						throw FormatError.overflow
					}
					character = formatString.character(advancing: &formatIndex)
				} while character.isNumber
				
				if character == "$" {
					if number > Int8.max {
						throw FormatError.overflow
					}
					if spec.precArgNum == -2 {
						spec.precArgNum = Int8(number - 1) // Arg numbers start from 1
					} else if spec.widthArgNum == -2 {
						spec.widthArgNum = Int8(number - 1) // Arg numbers start from 1
					} else {
						spec.mainArgNum = Int8(number - 1) // Arg numbers start from 1
					}
					break
				} else if seenDot { // else it's either precision or width
					if number > Int32.max {
						throw FormatError.overflow
					}
					spec.precArg = Int(number)
				} else {
					if number > Int32.max {
						throw FormatError.overflow
					}
					spec.widthArg = Int(number)
				}
				
				repeatSwitch = true
			case "*":
				spec.widthArgNum = -2
			case ".":
				seenDot = true
				character = formatString.character(advancing: &formatIndex)
				if character == "*" {
					spec.precArgNum = -2
				}
				repeatSwitch = true
			default:
				spec.type = .literal
				return spec
			}
		} while repeatSwitch
	}
	return spec
}
