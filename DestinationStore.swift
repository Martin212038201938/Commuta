import Foundation
import Combine
import CoreLocation
import SwiftUI

class DestinationStore: ObservableObject {
    @Published var destinations: [Destination] = [] {
        didSet {
            saveDestinations()
        }
    }
    @Published var selectedDestination: Destination?
    @Published var selectedTransportMode: TransportMode = .driving
    @Published var travelData: TravelData?
    @Published var isCountdownActive = false
    @Published var remainingMinutes: Int = 0
    @Published var timerString: String = "00:00"
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var userLocation: CLLocation?
    
    private let destinationsKey = "savedDestinations"
    
    init() {
        loadDestinations()
    }
    
    // MARK: - Destination Management
    
    func addDestination(_ destination: Destination) {
        destinations.append(destination)
    }
    
    func removeDestination(at indexSet: IndexSet) {
        destinations.remove(atOffsets: indexSet)
    }
    
    // MARK: - Persistence
    
    private func loadDestinations() {
        if let data = UserDefaults.standard.data(forKey: destinationsKey) {
            if let decoded = try? JSONDecoder().decode([Destination].self, from: data) {
                self.destinations = decoded
                return
            }
        }
        
        // Fallback zu Beispieldaten
        self.destinations = []
    }
    
    private func saveDestinations() {
        if let encoded = try? JSONEncoder().encode(destinations) {
            UserDefaults.standard.set(encoded, forKey: destinationsKey)
        }
    }
    
    // MARK: - Travel Time Calculation
    
    func updateUserLocation(_ location: CLLocation) {
        self.userLocation = location
        if isCountdownActive {
            calculateTravelTime()
        }
    }
    
    func startCountdown() {
        guard selectedDestination != nil, userLocation != nil else { return }
        
        isCountdownActive = true
        calculateTravelTime()
        
        // Setup timer for minute updates
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.calculateTravelTime()
        }
    }
    
    func stopCountdown() {
        isCountdownActive = false
        timer?.invalidate()
        timer = nil
        travelData = nil
        timerString = "00:00"
    }
    
    private func calculateTravelTime() {
        // In einem echten MVP würden wir hier die Google Directions API aufrufen
        // Für jetzt simulieren wir einfach Daten
        
        guard let destination = selectedDestination, let userLocation = userLocation else { return }
        
        // Simuliere API-Aufruf
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        let distanceInMeters = Int(userLocation.distance(from: destinationLocation))
        
        // Simuliere verschiedene Reisezeiten je nach Transportmittel
        var durationInSeconds = 0
        
        switch selectedTransportMode {
        case .driving:
            durationInSeconds = Int(Double(distanceInMeters) / 10) // ca. 36km/h
        case .walking:
            durationInSeconds = Int(Double(distanceInMeters) / 1.4) // ca. 5km/h
        case .transit:
            durationInSeconds = Int(Double(distanceInMeters) / 7) // ca. 25km/h + Wartezeit
        case .bicycling:
            durationInSeconds = Int(Double(distanceInMeters) / 4) // ca. 14km/h
        }
        
        // Formatiere Distanz und Zeit
        let distanceText: String
        if distanceInMeters < 1000 {
            distanceText = "\(distanceInMeters)m"
        } else {
            let distanceKm = Double(distanceInMeters) / 1000.0
            distanceText = String(format: "%.1f km", distanceKm)
        }
        
        let durationMinutes = durationInSeconds / 60
        let durationHours = durationMinutes / 60
        let remainingMinutes = durationMinutes % 60
        
        let durationText: String
        if durationHours > 0 {
            durationText = "\(durationHours) Std. \(remainingMinutes) Min."
        } else {
            durationText = "\(durationMinutes) Min."
        }
        
        // Aktualisiere Travel Data
        travelData = TravelData(
            durationInSeconds: durationInSeconds,
            durationText: durationText,
            distanceInMeters: distanceInMeters,
            distanceText: distanceText,
            departureTime: Date()
        )
        
        // Aktualisiere Countdown
        self.remainingMinutes = durationInSeconds / 60
        updateTimerString()
    }
    
    private func updateTimerString() {
        guard let travelData = travelData else { return }
        
        let minutes = travelData.durationInMinutes
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            timerString = String(format: "%02d:%02d", hours, remainingMinutes)
        } else {
            timerString = String(format: "00:%02d", minutes)
        }
        
        // Benachrichtigungen für Timer
        checkForNotifications()
    }
    
    private func checkForNotifications() {
        if remainingMinutes == 5 {
            // 5 Minuten Warnung
            sendNotification(title: "Fast losfahren!", body: "Noch 5 Minuten bis zur Abfahrt.")
        } else if remainingMinutes == 0 {
            // Zeit ist um
            sendNotification(title: "Zeit zu gehen!", body: "Es ist Zeit, zu \(selectedDestination?.name ?? "Ihrem Ziel") aufzubrechen.")
            
            // Spiele einen Alarm ab
            playAlarmSound()
        }
    }
    
    private func sendNotification(title: String, body: String) {
        // Wird in der vollständigen App implementiert
        print("Notification: \(title) - \(body)")
    }
    
    private func playAlarmSound() {
        // Wird in der vollständigen App implementiert
        print("ALARM: Zeit zu gehen!")
    }
}
