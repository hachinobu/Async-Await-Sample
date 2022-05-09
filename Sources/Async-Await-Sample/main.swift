import Foundation

func stream2() -> AsyncStream<Double> {
    return .init { c in
        c.yield(1)
        c.yield(2)
        c.finish()
    }
}

var streamTask: Task<Void, Never>?
func stream() -> AsyncThrowingStream<String, Error> {
    .init { c in
        c.onTermination = { termination in
            // streamが何により終了したのかを知ることができる
            switch termination {
            case .cancelled:
                // 親タスクがキャンセルされた場合にここに来る
                print("cancell")
//                c.finish(throwing: CE.w)
            case .finished(let e):
                print("fisnished-Termination!")
                // finishが呼ばれたときにくる
                // このStreamが終わったときの後処理の時とかに使う
                // finish()の場合とfinish(throwing: )の場合があるのでオプショナル
                print(e?.localizedDescription)
            @unknown default:
                break
            }
        }
        streamTask = Task {
            do {
                try Task.checkCancellation()
                let result = try await outputIntArray()
                c.yield(result.first!.description)
                c.yield(result[1].description)
                c.yield("a")
                c.yield("b")
                c.yield("c")
                try Task.checkCancellation()
                c.finish()
            } catch {
                print("stream error!")
                print(error.localizedDescription)
            }
        }
    }
}


//let rask = Task {
//    do {
//        let r = try await outputIntArray()
//        print(r.debugDescription)
//    } catch {
//        if Task.isCancelled {
//            print("Cansooooooo!!!")
//        }
//        print(error.localizedDescription)
//    }
//}
//
//rask.cancel()

//let rask2 = Task {
//    do {
//        let r = try await outputIntArray()
//        try Task.checkCancellation()
//        print(r.debugDescription)
//    } catch {
//        print("22222")
//        print(error.localizedDescription)
//    }
//}
//
//rask2.cancel()

//Task {
//    do {
//        print("start")
//        for try await s in streamm() {
//            print(s)
//        }
//        print("end")
//    } catch {
//        print("error!!!")
//        print(error.localizedDescription)
//    }
//    print("finish")
//}

//let ss = Task {
//    do {
//        for try await value in stream() {
//            print(value)
//        }
//        try Task.checkCancellation()
//    } catch {
//        print("errorr!!!!")
//        print(error.localizedDescription)
//    }
//    print("finish!!!")
//}
//

//Task {
//    do {
//        try await Task.sleep(nanoseconds: 3_000_000_000)
//        ss.cancel()
//    } catch {
//        print("e!!!!!!")
//    }
//}
//ss.cancel()


//let t = Task {
//    do {
//        for try await v in stream() {
//            print(v)
//        }
////            try Task.checkCancellation()
//        print("finish")
//    } catch {
//        print("error1: " + error.localizedDescription)
//    }
//}
//
////t.cancel()
//
//t.cancel()
//streamTask?.cancel()
//
//let sum = (0 ... 4).reduce(into: 0) { partialResult, i in
//    print(i)
//    partialResult = partialResult + i
//}
//print(sum)

//// async/await 直列実行パターン
//_ = serial()
//
//// async/await 並列実行パターン
//// async let版
//_ = asyncletParallel()
//
//// withThrowingTaskGroup
//_ = withThrowingTaskGroupParallel()
//
//// withThrowingTaskGroupの子タスクを並列にする
//_ = withThrowingTaskGroupChildTaskParallel()
//
//// BadPattern
//_ = badPatternAsynclet()



RunLoop.main.run()
