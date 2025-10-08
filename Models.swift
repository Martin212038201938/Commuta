import Foundation
import CoreLocation

struct Destination: Identifiable, Codable {
    var id = UUID()
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// Transportmittel für die Reise
enum TransportMode: String, CaseIterable, Identifiable, Codable {
    case driving = "Auto"
    case walking = "Zu Fuß"
    case transit = "ÖPNV"
    case bicycling = "Fahrrad"
    
    var id: String { self.rawValue }
    
    // Google Directions API Parameter
    var apiParam: String {
        switch self {
        case .driving: return "driving"
        case .walking: return "walking"
        case .transit: return "transit"
        case .bicycling: return "bicycling"
        }
    }
    
    // Icon für UI
    var icon: String {
        switch self {
        case .driving: return "car.fill"
        case .walking: return "figure.walk"
        case .transit: return "bus.fill"
        case .bicycling: return "bicycle"
        }
    }
}

// Model für die Reisedaten
struct TravelData: Codable {
    var durationInSeconds: Int
    var durationText: String
    var distanceInMeters: Int
    var distanceText: String
    var departureTime: Date
    
    // Berechnete Eigenschaft für Minuten
    var durationInMinutes: Int {
        return durationInSeconds / 60
    }
}
