import SwiftUI
import MapKit

struct AddDestinationView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var destinationStore: DestinationStore
    
    @State private var name = ""
    @State private var address = ""
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @State private var searchTerm = ""
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var showingResults = false
    @State private var selectedSearchResult: MKLocalSearchCompletion?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name (z.B. Büro, Arzt)", text: $name)
                    
                    VStack(alignment: .leading) {
                        if selectedSearchResult != nil {
                            // Zeige ausgewählte Adresse
                            Text(address)
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                            
                            Button("Adresse ändern") {
                                selectedSearchResult = nil
                                address = ""
                                searchTerm = ""
                            }
                            .foregroundColor(.blue)
                        } else {
                            // Zeige Adresssuche
                            TextField("Adresse suchen", text: $searchTerm)
                                .onChange(of: searchTerm) { newValue in
                                    showingResults = !newValue.isEmpty
                                    searchCompleter.queryFragment = newValue
                                }
                            
                            if showingResults && !searchResults.isEmpty {
                                List(searchResults, id: \.self) { result in
                                    Button(action: {
                                        selectSearchResult(result)
                                    }) {
                                        VStack(alignment: .leading) {
                                            Text(result.title)
                                                .foregroundColor(.primary)
                                            Text(result.subtitle)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .frame(minHeight: 200)
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: saveDestination) {
                        Text("Adresse speichern")
                    }
                    .disabled(name.isEmpty || address.isEmpty)
                }
            }
            .navigationTitle("Neue Adresse")
            .navigationBarItems(trailing: Button("Abbrechen") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // Simulierte Funktionen für den MVP
    private func selectSearchResult(_ result: MKLocalSearchCompletion) {
        selectedSearchResult = result
        address = "\(result.title), \(result.subtitle)"
        showingResults = false
        searchTerm = ""
        
        // In einer vollständigen App würden wir hier die Koordinaten über die Google Geocoding API abrufen
        // Für den MVP simulieren wir das mit Zufallskoordinaten in Deutschland
        
        // Deutschland liegt etwa zwischen 47-55°N und 6-15°O
        let randomLatitude = 47.0 + Double.random(in: 0...8)
        let randomLongitude = 6.0 + Double.random(in: 0...9)
    }
    
    private func saveDestination() {
        // Simuliere ein erfolgreiches Geocoding für den MVP
        // In einer echten App würden wir hier die tatsächlichen Koordinaten verwenden
        
        // Deutschland liegt etwa zwischen 47-55°N und 6-15°O
        let randomLatitude = 47.0 + Double.random(in: 0...8)
        let randomLongitude = 6.0 + Double.random(in: 0...9)
        
        let newDestination = Destination(
            name: name,
            address: address,
            latitude: randomLatitude,
            longitude: randomLongitude
        )
        
        destinationStore.addDestination(newDestination)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Simulierte Daten für den MVP
extension AddDestinationView {
    // Diese Erweiterung simuliert die Ergebnisse des MKLocalSearchCompleter
    // In einer echten App würden wir den echten Completer mit Google Places API integrieren
    
    func setupSearchCompleter() {
        // Im MVP simulieren wir die Ergebnisse der Adresssuche
        // In einer echten App würden wir Google Places API verwenden
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.searchTerm.isEmpty {
                self.searchResults = self.simulatedSearchResults(for: self.searchTerm)
            } else {
                self.searchResults = []
            }
        }
    }
    
    func simulatedSearchResults(for query: String) -> [MKLocalSearchCompletion] {
        // Simuliere Ergebnisse für die Adresssuche
        let completion1 = MKLocalSearchCompletion()
        completion1.setValue("Hauptstraße 123", forKey: "title")
        completion1.setValue("10115 Berlin, Deutschland", forKey: "subtitle")
        
        let completion2 = MKLocalSearchCompletion()
        completion2.setValue("Bahnhofstraße 45", forKey: "title")
        completion2.setValue("60329 Frankfurt, Deutschland", forKey: "subtitle")
        
        let completion3 = MKLocalSearchCompletion()
        completion3.setValue("Schlossallee 7", forKey: "title")
        completion3.setValue("80333 München, Deutschland", forKey: "subtitle")
        
        return [completion1, completion2, completion3]
    }
}

// MARK: - Preview
struct AddDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        AddDestinationView(destinationStore: DestinationStore())
    }
}
