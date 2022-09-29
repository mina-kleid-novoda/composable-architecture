import SwiftUI
import ComposableArchitecture

struct CounterView: View {
    let store: Store<Counter.State, Counter.Action>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Text("Timer[\(viewStore.isTimerOn ? "ON" : "OFF" )]: \(viewStore.timer)")
                    .padding()
                Text("\(viewStore.counter) is \(viewStore.isEvenNumber ? "even" : "odd")")

                HStack{
                    Button("-") {
                        viewStore.send(.decrementTapped)
                    }
                    Text("\(viewStore.counter)")
                    Button("+") {
                        viewStore.send(.incrementTapped)
                    }
                }
            }
            .onDisappear{ viewStore.send(.resetTimer) }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(
            store: Store(
                initialState: Counter.State(),
                reducer: counterReducer,
                environment: .init(queue: DispatchQueue.main.eraseToAnyScheduler())
            )
        )
    }
}
