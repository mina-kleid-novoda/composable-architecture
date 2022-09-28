import SwiftUI
import ComposableArchitecture

/**
 Questions:
 1. When to slice the state & reducer
 2. Cancellation of the timer
 3. How many actions an effect can send
 4. State Modeling that maintainable & scalable
 
 
 Tasks:
 1. Add app environment
 2. Bundle the counter & isEvenNumber into one State
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
    let dispatchQueue: DispatchQueue
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


struct CounterView: View {
    let store: Store<CounterViewState, CounterViewAction>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .padding()
                
                if(viewStore.isTimerOn) {
                    Text("\(viewStore.timer)")
                }
                
                if(viewStore.isEvenNumber) {
                    Text("Even says Hello")
                } else {
                    Text("Odd doesnt say Hello")
                }
                
                HStack{
                    Button("-"){
                        viewStore.send(.decrementTapped)
                    }
                    Text("\(viewStore.counter)")
                    Button("+"){
                        viewStore.send(.incrementTapped)
                    }
                }.padding()
                
            }.padding()
                .onDisappear{ viewStore.send(.onDisappear) }
        }
    }
}


let startTimer: (CounterViewEnvironment) -> Effect<CounterViewAction, Never> = { environment in
    return .run { send in
        await send(.timerStarted)
        for await _ in environment.dispatchQueue.timer(interval: 1) {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(store: Store(
            initialState: CounterViewState(),
            reducer: reducer.debug(),
            environment: CounterViewEnvironment(
                dispatchQueue: DispatchQueue.main)
        )
        )
    }
}
