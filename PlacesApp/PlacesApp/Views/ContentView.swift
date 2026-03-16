import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MonitoredPlacesView()
                .tabItem {
                    Label("Places", systemImage: "mappin.and.ellipse")
                }

            PlaceSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}
