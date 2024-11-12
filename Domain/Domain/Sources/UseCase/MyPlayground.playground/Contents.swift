import Foundation

var a: Int?

func test() -> Int? {
    a = 1
    defer { a = nil }
    return a
}

print(test())
