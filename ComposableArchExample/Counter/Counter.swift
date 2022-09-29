import Foundation
import ComposableArchitecture

public enum Counter {
    public struct State: Equatable {
        public var counter: Int = 0 {
            didSet {
                isEvenNumber = counter % 2 == 0
            }
        }
        public var isEvenNumber: Bool = false
        public var isTimerOn: Bool = false
        public var timer: Int = 0

        public init(counter: Int = 0, isEvenNumber: Bool = false, isTimerOn: Bool = false, timer: Int = 0) {
            self.counter = counter
            self.isEvenNumber = isEvenNumber
            self.isTimerOn = isTimerOn
            self.timer = timer
        }
    }

    public enum Action: Equatable {
        case incrementTapped
        case decrementTapped

        case timerStarted
        case incrementTimer
        case resetTimer
    }

    public struct Environment {
        let queue: AnySchedulerOf<DispatchQueue>

        public init(queue: AnySchedulerOf<DispatchQueue> = .main) {
            self.queue = queue
        }
    }
}

public let counterReducer = Reducer<Counter.State, Counter.Action, Counter.Environment> { state, action, environment in
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
            return state.isTimerOn ? Effect(value: .resetTimer) : .none
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
