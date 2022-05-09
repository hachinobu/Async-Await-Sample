//
//  File.swift
//  
//
//  Created by Takahiro Nishinobu on 2022/05/09.
//

import Foundation

func singleTask() {
    Task {
        try await sleep(seconds: 1)
        print("finish")
    }
}

// Taskとは並行処理の単位である
func twoTask() {
    print("start " + #function.debugDescription)
    Task {
        try await sleep(seconds: 2)
        print("finish sleep 2")
    }
    Task {
        try await sleep(seconds: 1)
        print("finish sleep 1")
    }
}

// 3つの並行処理
func multiTasks() -> Int {
    print("start " + #function.debugDescription)
    // ここで呼び出しているメソッドはTaskを返すがasyncなメソッドでないので非同期の同期はできない
    // それぞれ勝手に処理が走って勝手に終わるだけでできるのはtaskのキャンセルなどだけ
    serial()
    asyncletParallel()
    asyncStream()
    print("end " + #function.debugDescription)
    // 呼び出している３つの非同期処理が終わる前にendと返り値の3が呼び出し元に返される
    return 3
}

// 3つの並行処理の完了を待ってから値を返したい場合
func asyncTask() async -> Int {
    print("start " + #function.debugDescription)
    // Taskにはそのタスクの結果であるresultというプロパティが存在していて、これがasyncの設計になっている
    // public var result: Result<Success, Failure> { get async }
    // もしくはResult<Success, Failure>のSuccessの方を取得するvalueプロパティが存在しておりvalueが取れない場合はErrorがthrowされる
    // public var value: Success { get async throws }
    _ = await serial().result
    _ = await asyncletParallel().result
    _ = await asyncStream().result
    print("end " + #function.debugDescription)
    return 3
}

func parentTask() -> Task<Void, Error> {
    Task {
        print("start " + #function.debugDescription)
        // .valueでエラーがthrowされた場合はTaskResultに代入される
        _ = try await serial().value
        _ = try await asyncletParallel().value
        _ = try await asyncStream().value
        print("end " + #function.debugDescription)
    }
}

func cancelSingleTask() -> Task<Void, Never> {
    let task = Task {
        _ = await serial().result
        if Task.isCancelled {
            // ここは通る
            print("Canceled!!!")
        }
    }
    task.cancel()
    if Task.isCancelled {
        // ここにはこない
        print("Task.isCancelled!!!")
    }
    return task
}

// Task.sleep(nanoseconds: メソッドはキャンセルするとCancellationErrorをthrowする仕様になっている
// public static func sleep(nanoseconds duration: UInt64) async throws
func sleepCancel() -> Task<Void, Error> {
    let task = Task {
        try await sleep(seconds: 3)
    }
    // cancel()を実行することでTaskのresultにCancellationErrorが代入される
    task.cancel()
    return task
}
