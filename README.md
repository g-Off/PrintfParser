# PrintfParser

A Swift `printf` style string parser that will return the various arguments found.
`let specs = try "There are %d apple".formatSpecifiers()` will return an array of `Spec` instances. In this case a single one will be returned the contains the index and length of the `%d` portion of the string as well as information about the replacement type. Localized strings are fully supported (in fact, anything that `CFString` supports should be supported by this library).

Heavily based on Apple's CFString implementation (`__CFParseFormatSpec`).
