//
//  File.swift
//  
//
//  Created by Takahiro Nishinobu on 2022/04/27.
//

import Foundation

enum MyError: Error {
    case e1
    case e2
}

func sleep(seconds: Int = 1) async throws {
    print("sleep start")
    try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    print("sleep finish")
}

func outputInt(num: Int) async -> Int {
    print("outputInt")
    return num
}

func outputIntArray() async throws -> [Int] {
    print("start " + #function.debugDescription)
    try await Task.sleep(nanoseconds: 2_000_000_000)
    print("outputIntArray sleep finish")
    return [1, 2, 3, 4]
}

func throwsE1() throws {
    throw MyError.e1
}
