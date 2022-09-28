import SwiftUI
import ComposableArchitecture

@main
struct ComposableArchExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                NavigationLink("Navigation"){
                    CounterView(store: Store(initialState: CounterViewState(),
                                             reducer: reducer.debug(),
                                             environment: CounterViewEnvironment(dispatchQueue: DispatchQueue.main)))
                    
                }.navigationTitle("Main view")
            }
        }
    }
}
