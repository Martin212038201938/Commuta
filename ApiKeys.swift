import Foundation

// In einer echten App müssten hier die tatsächlichen API-Schlüssel eingetragen werden
// Für den MVP verwenden wir Platzhalter

struct ApiKeys {
    // Für Google Places API
    static let googlePlacesApiKey = "YOUR_GOOGLE_PLACES_API_KEY"
    
    // Für Google Directions API
    static let googleDirectionsApiKey = "YOUR_GOOGLE_DIRECTIONS_API_KEY"
}

// Diese Datei sollte in der .gitignore aufgeführt werden, damit sie nicht ins Repository hochgeladen wird
// Für die Veröffentlichung im App Store sollten die API-Schlüssel sicher gespeichert werden, z.B. mit Hilfe von Umgebungsvariablen oder einem sicheren Schlüsselspeicher
