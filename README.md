# Commuta - Pünktlich ankommen

Commuta ist eine Web-App, die Ihnen hilft, pünktlich zu Ihren Zielen zu kommen. Die App berechnet die aktuelle Reisezeit basierend auf dem gewählten Verkehrsmittel und Ihrem aktuellen Standort, und zeigt einen Countdown an, der angibt, wann Sie losgehen müssen.

## Features des MVP

- Speichern von Zieladressen mit Adressvervollständigung (simuliert im MVP)
- Auswahl des Verkehrsmittels (Auto, ÖPNV, Fahrrad, zu Fuß)
- Berechnung der aktuellen Reisezeit vom aktuellen Standort (simuliert im MVP)
- Countdown-Timer, der anzeigt, wann Sie losgehen müssen
- Benachrichtigungen und Alarme vor der Abfahrtszeit
- Automatische minütliche Aktualisierung der Reisedaten

## Technischer Stack

- **Frontend**: HTML, CSS, JavaScript (Vanilla JS)
- **Backend**: n8n-Workflows
  - Travel Time API für die Berechnung der Reisezeit
  - Places Search API für die Adressvervollständigung
- **Datenspeicherung**: localStorage für die Zieladressen

## Installation und Setup

### Frontend

1. Klonen Sie dieses Repository:
   ```
   git clone https://github.com/Martin212038201938/Commuta.git
   ```

2. Öffnen Sie die Datei `index.html` in einem modernen Webbrowser.

### n8n Workflows

1. Importieren Sie die beiden Workflow-Dateien in Ihre n8n-Instanz:
   - `Commuta - Travel Time API.json`
   - `Commuta - Places Search API.json`

2. Aktivieren Sie die Webhooks in n8n.

3. Für die Produktion ersetzen Sie die Dummy-API-Keys in den Workflows durch echte Google API-Keys:
   - Google Maps Directions API für die Reisezeitberechnung
   - Google Places API für die Adressvervollständigung

## Verwendung

1. Fügen Sie Ziele hinzu, indem Sie auf "Neues Ziel hinzufügen" klicken und die Adressinformationen eingeben.

2. Wählen Sie ein Ziel aus der Liste, um einen Countdown zu starten.

3. Wählen Sie das gewünschte Verkehrsmittel (Auto, ÖPNV, Fahrrad, zu Fuß).

4. Starten Sie den Countdown mit "Countdown starten".

5. Die App berechnet die Reisezeit und zeigt einen Countdown an, wann Sie losgehen müssen.

6. Sie erhalten Benachrichtigungen, wenn es Zeit ist zu gehen.

## Nächste Schritte nach dem MVP

1. **API-Integration**:
   - Echte Integration mit Google Maps API für genaue Routenberechnungen
   - Integration mit Google Places API für Adressvervollständigung

2. **Erweiterte Features**:
   - Regelmäßige Termine speichern (z.B. Arbeit, Arzttermine, etc.)
   - Verkehrsstörungen und -prognosen einbeziehen
   - Öffentliche Verkehrsinformationen in Echtzeit

3. **UX-Verbesserungen**:
   - Kartenansicht für Start- und Zielpunkte
   - Anzeige der Route
   - Farbkodierte Warnungen basierend auf der verbleibenden Zeit

4. **Plattformspezifische Apps**:
   - Native iOS-App mit Swift
   - Native Android-App mit Kotlin

5. **Monetarisierung**:
   - Premium-Version mit erweiterten Features
   - Werbeintegration für die kostenlose Version

## Hinweise zur Verwendung des MVPs

- Die Adressvervollständigung und Reisezeitberechnung werden im MVP simuliert.
- Die tatsächliche Anbindung an die Google APIs erfolgt in einem späteren Update.
- Stellen Sie sicher, dass Ihr Browser Standortzugriff erlaubt, damit die App Ihren aktuellen Standort ermitteln kann.
- Die App verwendet localStorage zur Speicherung der Ziele. Diese werden nur lokal in Ihrem Browser gespeichert und gehen verloren, wenn Sie den Browser-Cache löschen.

## Lizenz

© 2025 Martin - Alle Rechte vorbehalten
