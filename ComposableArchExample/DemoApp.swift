import SwiftUI
import ComposableArchitecture

@main
struct DemoApp: DemoApp {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                NavigationLink("Navigation"){
                    CounterView(
                        store: Store(
                            initialState: Counter.State(),
                            reducer: reducer.debug(),
                            environment: .init(queue: .main)
                        )
                    )
                    
                }.navigationTitle("Main view")
            }
        }
    }
}
