import Foundation
import ComposableArchitecture

enum Counter {
    struct State: Equatable {
        var counter: Int = 0 {
            didSet {
                isEvenNumber = counter % 2 == 0
            }
        }
        var isEvenNumber: Bool = false
        var isTimerOn: Bool = false
        var timer: Int = 0
    }

    enum Action: Equatable {
        case incrementTapped
        case decrementTapped

        case timerStarted
        case incrementTimer
        case resetTimer
    }

    struct Environment {
        let queue: DispatchQueue
    }
}

let reducer = Reducer<Counter.State, Counter.Action, Counter.Environment> { state, action, environment in
    enum TimerID {}
    let MAX_COUNTER = 100

    switch action {
    case .incrementTapped:
        state.counter += 1
        return handleTimer(&state)
    case .decrementTapped:
        state.counter -= 1
        return handleTimer(&state)
    case .timerStarted:
        state.isTimerOn = true
        return .none
    case .incrementTimer:
        state.timer += 1
        return .none
    case .resetTimer:
        state.isTimerOn = false
        state.timer = 0
        return .cancel(id: TimerID.self)
    }

    func handleTimer(_ state: inout Counter.State) -> Effect<Counter.Action, Never> {
        if (state.isEvenNumber) {
            return startTimer()
        } else {
            return .init(value: .resetTimer)
        }
    }

    func startTimer() -> Effect<Counter.Action, Never> {
        return .run { send in
            await send(.timerStarted)
            for _ in 0...MAX_COUNTER {
                try await environment.queue.sleep(for: 0.05)
                await send(.incrementTimer)
            }
            await send(.resetTimer)
        }.cancellable(id: TimerID.self)
    }
}
