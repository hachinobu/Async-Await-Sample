//
//  File.swift
//  
//
//  Created by Takahiro Nishinobu on 2022/04/27.
//

import Foundation

// async/await 並列実行パターン

// async letによる並列実行
func parallel1() -> Task<Void, Error> {
    Task {
        print("start " + #function.debugDescription)
        async let sleepResult: () = sleep(seconds: 3)
        async let outputResult = outputIntArray()
        let (_, result) = try await(sleepResult, outputResult)
        print("result: " + result.description)
    }
}

// 
