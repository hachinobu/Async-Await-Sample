import Foundation

func sleep(nanoseconds: Int = 1) async throws {
    print("sleep start")
    try await Task.sleep(nanoseconds: UInt64(nanoseconds * 1_000_000_000))
    print("sleep finish")
}

func outputInt(num: Int) async -> Int {
    print("outputInt")
    return num
}

func outputIntArray() async throws -> [Int] {
    print("outputIntArray")
    try await Task.sleep(nanoseconds: 2_000_000_000)
    return [1, 2, 3, 4]
}

// 1. 直列パターン
Task {
    print("start 1.")
    let num = try await outputIntArray()[0]
    let result = await outputInt(num: num)
    print("1. result: " + result.description)
}

// 2. 並列実行パターン（async let版）
Task {
    print("start 2.")
    async let sleepResult: () = sleep()
    async let outputResult = outputInt(num: 1)
    let (_, result) = try await(sleepResult, outputResult)
    print("2. result: " + result.description)
}

// 3. 並列実行パターン（withThrowingTaskGroup）
Task {
    print("start 3.")
    let nums = try await outputIntArray()
    await withThrowingTaskGroup(of: [Int].self) { group in
        for _ in nums {
            group.addTask {
                try await outputIntArray()
            }
        }
    }
}

// 4. 並列実行パターン（withThrowingTaskGroupのタスク内を更に並列実行したい時）
Task {
    print("start 4.")
    let nums = try await outputIntArray()
    let result = try await withThrowingTaskGroup(of: Int.self) { group -> Int in
        for num in nums {
            group.addTask() {
                async let sleepResult: () = sleep(nanoseconds: num)
                async let numResult = outputInt(num: num)
                let (_, n) = try await(sleepResult, numResult)
                return n
            }
        }
        return try await group.reduce(0, +)
    }
    print("4. result: " + result.description)
}

// 5. async letの変数をwithThrowingTaskGroup内ではawaitなしで使える（withThrowingTaskGroupの先頭でawait書くため）
Task {
    print("start 5.")
    async let sleepResult: () = sleep(nanoseconds: 4)
    async let outputNums = outputIntArray()
    try await withThrowingTaskGroup(of: Int.self) { [sleepResult, outputNums] group in
        for num in outputNums {
            group.addTask {
                let _ = sleepResult
                let num = await outputInt(num: num)
                return num
            }
        }
        // groupTaskの返り値が同じ場合は下記のように書ける
        group.addTask {
            await outputInt(num: 1)
        }
    }
}

// 6. 並列実行のバットパターン（これは並列には実行されない）
Task {
    // sleepが実行された後にoutputIntが処理される
    async let (sleepResult, outputResult) = (sleep(nanoseconds: 5), outputInt(num: 2))
//    let t = try await outputResult
//    print(t)
    let (_, result) = try await(sleepResult, outputResult)
    print("6. result: " + result.description)
}


RunLoop.main.run()
