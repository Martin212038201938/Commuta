import SwiftUI

struct DestinationPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var destinationStore: DestinationStore
    
    @State private var selectedDestinationId: UUID?
    @State private var selectedTransportMode: TransportMode = .driving
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Ziel auswählen")) {
                        if destinationStore.destinations.isEmpty {
                            Text("Keine Ziele gespeichert")
                                .foregroundColor(.gray)
                            
                            Button("Neues Ziel hinzufügen") {
                                // Diese Funktion müsste in ContentView implementiert werden
                            }
                        } else {
                            ForEach(destinationStore.destinations) { destination in
                                Button(action: {
                                    selectedDestinationId = destination.id
                                    destinationStore.selectedDestination = destination
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(destination.name)
                                                .font(.headline)
                                            
                                            Text(destination.address)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedDestinationId == destination.id {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: deleteDestination)
                        }
                    }
                    
                    if selectedDestinationId != nil {
                        Section(header: Text("Verkehrsmittel")) {
                            ForEach(TransportMode.allCases) { mode in
                                Button(action: {
                                    selectedTransportMode = mode
                                    destinationStore.selectedTransportMode = mode
                                }) {
                                    HStack {
                                        Image(systemName: mode.icon)
                                            .foregroundColor(.blue)
                                        
                                        Text(mode.rawValue)
                                        
                                        Spacer()
                                        
                                        if selectedTransportMode == mode {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
                if selectedDestinationId != nil {
                    Button(action: {
                        startCountdown()
                    }) {
                        Text("Countdown starten")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Ziel auswählen")
            .navigationBarItems(trailing: Button("Abbrechen") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func deleteDestination(at offsets: IndexSet) {
        destinationStore.removeDestination(at: offsets)
    }
    
    private func startCountdown() {
        // Starte den Countdown in DestinationStore
        destinationStore.startCountdown()
        
        // Schließe den Dialog
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Preview
struct DestinationPickerView_Previews: PreviewProvider {
    static var previews: some View {
        let store = DestinationStore()
        // Füge Beispieldaten für die Vorschau hinzu
        store.destinations = [
            Destination(name: "Büro", address: "Hauptstraße 123, Berlin", latitude: 52.520008, longitude: 13.404954),
            Destination(name: "Zuhause", address: "Musterstraße 45, Berlin", latitude: 52.530008, longitude: 13.414954)
        ]
        
        return DestinationPickerView(destinationStore: store)
    }
}
