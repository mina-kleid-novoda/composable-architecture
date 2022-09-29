import Foundation
import ComposableArchitecture
/**
Tasks:
- Fix Bug: Counter stops when number is odd, but timer is in inconsistent state
 */

struct CounterViewState: Equatable {
    var counter: Int = 0
    var isEvenNumber: Bool = false
    var isTimerOn: Bool = false
    var timer: Int = 0
}

enum CounterViewAction: Equatable {
    case incrementTapped
    case decrementTapped

    case timerStarted
    case incrementTimer
    case timerFinished

    case onDisappear
}

struct CounterViewEnvironment {
    let queue: DispatchQueue
}

fileprivate enum TimerID {}

let reducer = Reducer<CounterViewState, CounterViewAction, CounterViewEnvironment> { state, action, environment in

    switch action {
    case .incrementTapped:
        state.counter += 1
        state.isEvenNumber = state.counter % 2 == 0
        return handleTimer(state.isEvenNumber, environment)
    case .decrementTapped:
        state.counter -= 1
        state.isEvenNumber = state.counter % 2 > 0
        return handleTimer(state.isEvenNumber, environment)
    case .timerStarted:
        state.isTimerOn = true
        return .none
    case .incrementTimer:
        guard state.isTimerOn, state.timer < 5 else {
            return Effect(value: .timerFinished)
        }
        state.timer += 1
        return .none
    case .timerFinished:
        state.isTimerOn = false
        state.timer = 0
        return .cancel(id: TimerID.self)
    case .onDisappear:
        return .cancel(id: TimerID.self)
    }
}

let startTimer: (CounterViewEnvironment) -> Effect<CounterViewAction, Never> = { environment in
    return .run { send in
        await send(.timerStarted)
        for await _ in environment.queue.timer(interval: 1) {
            await send(.incrementTimer)
        }
    }.cancellable(id: TimerID.self)
}

let handleTimer: (Bool, CounterViewEnvironment) -> Effect<CounterViewAction, Never>  = { isEvenNumber, environment in
    if (isEvenNumber) {
        return startTimer(environment)
    } else {
        return .cancel(id: TimerID.self)
    }
}
