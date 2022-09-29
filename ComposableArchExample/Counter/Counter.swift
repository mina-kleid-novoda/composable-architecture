import Foundation
import ComposableArchitecture

struct CounterViewState: Equatable {
    var counter: Int = 0 {
        didSet {
            isEvenNumber = counter % 2 == 0
        }
    }
    var isEvenNumber: Bool = false
    var isTimerOn: Bool = false
    var timer: Int = 0
}

enum CounterViewAction: Equatable {
    case incrementTapped
    case decrementTapped

    case timerStarted
    case incrementTimer
    case resetTimer

    case onDisappear
}

struct CounterViewEnvironment {
    let queue: DispatchQueue
}

fileprivate enum TimerID {}

let reducer = Reducer<CounterViewState, CounterViewAction, CounterViewEnvironment> { state, action, environment in
    let MAX_COUNTER = 5
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
        return stopTimer()
    case .onDisappear:
        return stopTimer()
    }

    func handleTimer(_ state: inout CounterViewState) -> Effect<CounterViewAction, Never> {
        if (state.isEvenNumber) {
            return startTimer()
        } else {
            return Effect(value: .resetTimer)
        }
    }

    func startTimer() -> Effect<CounterViewAction, Never> {
        return .run { send in
            await send(.timerStarted)
            for _ in 0...MAX_COUNTER {
                try await environment.queue.sleep(for: 1)
                await send(.incrementTimer)
            }
            await send(.resetTimer)
        }.cancellable(id: TimerID.self)
    }

    func stopTimer() -> Effect<CounterViewAction, Never> {
        return .cancel(id: TimerID.self)
    }
}
