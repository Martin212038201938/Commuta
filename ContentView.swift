import SwiftUI

struct ContentView: View {
    @StateObject private var destinationStore = DestinationStore()
    @EnvironmentObject var locationManager: LocationManager
    @State private var isShowingDestinationPicker = false
    @State private var isShowingAddDestination = false
    
    var body: some View {
        NavigationView {
            VStack {
                if destinationStore.isCountdownActive, let destination = destinationStore.selectedDestination {
                    // Countdown-Ansicht
                    CountdownView(
                        destination: destination,
                        transportMode: destinationStore.selectedTransportMode,
                        timerString: destinationStore.timerString,
                        travelData: destinationStore.travelData
                    )
                    .padding()
                    
                    Button(action: {
                        destinationStore.stopCountdown()
                    }) {
                        Text("Countdown stoppen")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                } else {
                    // Startansicht
                    Button(action: {
                        isShowingDestinationPicker = true
                    }) {
                        Text("Wohin möchten Sie fahren?")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Image(systemName: "timer")
                        .font(.system(size: 100))
                        .foregroundColor(.gray)
                    
                    Text("Commuta hilft Ihnen, pünktlich anzukommen!")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("Commuta")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingAddDestination = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingDestinationPicker) {
                DestinationPickerView(destinationStore: destinationStore)
            }
            .sheet(isPresented: $isShowingAddDestination) {
                AddDestinationView(destinationStore: destinationStore)
            }
            .onChange(of: locationManager.location) { newLocation in
                if let location = newLocation {
                    destinationStore.updateUserLocation(location)
                }
            }
        }
    }
}

struct CountdownView: View {
    let destination: Destination
    let transportMode: TransportMode
    let timerString: String
    let travelData: TravelData?
    
    var body: some View {
        VStack(spacing: 20) {
            Text(destination.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(destination.address)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: transportMode.icon)
                    .font(.title)
                Text(transportMode.rawValue)
                    .font(.headline)
            }
            .padding(.vertical, 5)
            
            if let travelData = travelData {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Entfernung:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(travelData.distanceText)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Fahrzeit:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(travelData.durationText)
                            .font(.headline)
                    }
                }
                .padding(.vertical)
            }
            
            Text("Verbleibende Zeit")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(timerString)
                .font(.system(size: 70, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocationManager())
    }
}
