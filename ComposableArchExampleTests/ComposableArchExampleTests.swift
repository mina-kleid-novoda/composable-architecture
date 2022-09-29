import XCTest
import ComposableArchitecture
@testable import ComposableArchExample

final class ComposableArchExampleTests: XCTestCase {
    let scheduler = DispatchQueue.test

    @MainActor
    func testInitialState() throws {
        let store = TestStore(
            initialState: Counter.State(),
            reducer: counterReducer,
            environment: .init()
        )

        store.send(.incrementTapped) { state in
            state.counter = 1
            state.isEvenNumber = false
        }
    }

    @MainActor
    func testStartTimerOnEven() async throws {
        let store = TestStore(
            initialState: Counter.State(counter: 1, isEvenNumber: false),
            reducer: counterReducer,
            environment: .init(queue: scheduler.eraseToAnyScheduler())
        )

        await _ = store.send(.incrementTapped) { state in
            state.counter = 2
            state.isEvenNumber = true
        }

        await store.receive(.timerStarted) { state in
            state.isTimerOn = true
        }

        await scheduler.advance(by: 0.05)

        await store.receive(.incrementTimer) { state in
            state.timer = 1
        }

        await _ = store.send(.resetTimer) { state in
            state.isTimerOn = false
            state.timer = 0
        }
    }
}
