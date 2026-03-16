import SwiftUI

@main
struct PlacesAppApp: App {
    @StateObject private var store = PlaceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
